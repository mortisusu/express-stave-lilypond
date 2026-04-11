% This is free and unencumbered software released into the public domain.

% Anyone is free to copy, modify, publish, use, compile, sell, or
% distribute this software, either in source code form or as a compiled
% binary, for any purpose, commercial or non-commercial, and by any
% means.

% In jurisdictions that recognize copyright laws, the author or authors
% of this software dedicate any and all copyright interest in the
% software to the public domain. We make this dedication for the benefit
% of the public at large and to the detriment of our heirs and
% successors. We intend this dedication to be an overt act of
% relinquishment in perpetuity of all present and future rights to this
% software under copyright law.

% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
% OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
% ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
% OTHER DEALINGS IN THE SOFTWARE.

% For more information, please refer to <https://unlicense.org/>

% ======================================================================

% This work is a LilyPond implementation of the Express Stave notation 
% system by John Keller
% Read more about it in the links below
%   https://musicnotation.org/system/express-stave-by-john-keller/
%   https://musicnotation.org/wiki/notation-systems/express-stave-by-john-keller/

% This code is based on the MNP-scripts.ly downloaded from 
%   https://musicnotation.org/wiki/software/lilypond/

% Parts of the double-stem code are based on the clairnote.ly code by Paul Morris
%   https://gitlab.com/paulmorris/lilypond-clairnote

\version "2.24.0"
#(define ES_VERSION "1.26.04.11")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Express Stave default variables
%%%% In order to override, set express-* BEFORE including this script

% staff spacing
#(define express-staff-space
   (* 0.6 (if (defined? 'express-staff-space) express-staff-space 1)))
       
#(define PIANOFORTE-DEFAULT 1)
% if 1, white piano keys are denoted by black noteheads
#(define express-pianoforte
   (if (defined? 'express-pianoforte)
       express-pianoforte
       PIANOFORTE-DEFAULT))

% if 1, pianoroll markings are displayed to the left of the staff lines, making it easier to identify the notes
#(define express-showpianoroll
   (if (defined? 'express-showpianoroll)
       express-showpianoroll
       0))

% if 0, stems are similar to classic notation, but minims (half notes) and semibreves (whole notes) 
%       have a different notehead.
% if > 0, two stems are drawn for minims , and three for semibreves
% if > 1, dots are unified
#(define express-multi-stems
   (if (defined? 'express-multi-stems)
       express-multi-stems
       2))


#(define unify-dots? 
   (if (defined? 'express-multi-stems)
       (> express-multi-stems 1)
       #f))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% HELPER FUNCTIONS - USABLE BY LILYPOND USERS


%%%% helper shorthand function to fix "no viable initial configuration found: may not find good beam slope" warnings
%%%% usage: \beampos <y-start> <y-end>
beampos =
#(define-music-function (x y) (number? number?)
   #{
     \once \override Beam.positions = #(cons x y)
   #})


%%%% helper shorthand functions to offset a note in a chord, when there are crammed notes on top of each other
shiftl =
#(define-music-function (note) (ly:music?)
   #{
     \tweak extra-offset #'(-1.6 . 0) #note
   #})

shiftr =
#(define-music-function (note) (ly:music?)
   #{
     \tweak extra-offset #'(1.5 . 0) #note
   #})

%%%% helper shorthand function to shift an entire note (including its stem). Useful if notes are colliding visually.
hshift =
#(define-music-function (x) (number?)
   #{
     \once \override NoteColumn.force-hshift = #x
   #})


% shift note heads. Place before a chord, and define the shift of each note. Example usage:
% \snhs #'(-1 0 0 0)
% <c d e f>4
snhs =
#(define-music-function (offsets) (list?)

 #{
    \once \override NoteColumn.before-line-breaking = #(shift-notes offsets)
 #})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% INTERNAL CODE STARTS HERE

#(define D-NOTES 0)  
#(define D-ALL 2)
#(define (debug-levels level debug-mode msg params)
   (if (>= debug-mode level)
       (begin
         (display (apply format #f msg params))
         (newline))))

#(define (debug debug-mode msg . params) (debug-levels 2 debug-mode msg params))
#(define (info debug-mode msg . params) (debug-levels 1 debug-mode msg params))

% calculate the size of an extent (usually retrieved using ly:grob-extent)
#(define (extent-size extent)
  (abs (- (cdr extent) (car extent))))

#(define (stencil-size stencil dim)
  (extent-size (ly:stencil-extent stencil dim)))

#(define (center-glyph glyph)
  (let* (
          (glyph-x-ext (ly:stencil-extent glyph X))
          (glyph-width (- (cdr glyph-x-ext) (car glyph-x-ext)))
          (glyph-y-ext (ly:stencil-extent glyph Y))
          (glyph-height (- (cdr glyph-y-ext) (car glyph-y-ext)))

          (x-translate (- 0 (car glyph-x-ext) (/ glyph-width 2)))
          (y-translate (- 0 (car glyph-y-ext) (/ glyph-height 2)))
          (res (ly:stencil-translate glyph (cons x-translate y-translate)))
          ;(res (ly:stencil-scale translated 1 1)) ;(/ 1.1 glyph-height)
      )

  ; (debug D-ALL "center-glyph x: ~a, y: ~a, width: ~a, height: ~a" (ly:stencil-extent res X) (ly:stencil-extent res Y) (stencil-size res X) (stencil-size res Y))
  res
))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% STENCILS

%% Converting images to Lilypond path data:
%% 1. Create a b/w png image
%% 2. Convert them into svg files
%%    a) via https://picsvg.com/ Using Details: Strong, Filters: Internal 4,
%%    b) via Inkscape: Import png, Path > Trace Bitmap, Path > Simplify
%% 3. Convert the svg files to lilypond paths using: bin/sv2lypath.py

%% CUSTOM CLEFS

#(define clef-factor 0.8)

% generated by running: python bin/svg2lypath.py assets/express-b-int4-w.svg 4.9 0 -0.17 -p0
express-clef-b = #'(
moveto 1.705 4.067 curveto 1.632 4.069 0.808 4.058 0.82 2.754 curveto 0.823 2.482 0.955 0.885
1.052 0.378 curveto 0.741 0.49 0.253 0.54 0 0.238 curveto -0.296 -0.115 0.184 -0.553 0.762
-0.433 curveto 1.336 -0.291 1.285 -0.124 1.18 1.209 curveto 1.082 2.86 1.188 3.446 1.577 3.434
curveto 1.999 3.423 1.989 2.391 1.322 1.449 lineto 1.573 1.337 curveto 2.184 1.064 2.399 0.737
2.328 0.187 curveto 2.143 -0.622 1.382 -0.754 0.751 -0.687 curveto 0.752 -0.689 0.724 -0.767 0.724
-0.774 curveto 0.832 -0.804 1.083 -0.834 1.29 -0.833 curveto 2.552 -0.833 3.299 -0.131 2.996 0.769
curveto 2.804 1.459 1.946 1.573 1.627 1.55 curveto 1.627 1.55 1.68 1.655 1.868 1.913 curveto
2.141 2.29 2.316 2.642 2.377 2.935 curveto 2.5 3.534 2.16 4.057 1.705 4.067 closepath

)

% generated by running: python bin/svg2lypath.py assets/express-b-int4-w.svg 3.5 0 -0.05 -p1
express-clef-b-orig = #'(
moveto 0.575 0.218 curveto 0.752 0.21 1.013 0.17 0.996 -0.015 curveto 0.983 -0.149 0.857 -0.232
0.6 -0.241 curveto 0.344 -0.249 0.128 -0.131 0.149 0.034 curveto 0.17 0.199 0.418 0.226 0.575
0.218 closepath

)

expressBClefPianoforte = #(make-path-stencil express-clef-b 0.0 clef-factor clef-factor #t)
expressBClefOriginal = #(make-path-stencil (append express-clef-b express-clef-b-orig) 0.0 clef-factor clef-factor #t)


% generated by running: python bin/svg2lypath.py assets/express-f-int4-w.svg 3.98 0 -0.74 -p0,2
express-clef-f = #'(
moveto 1.463 1.035 curveto 1.363 1.033 1.258 1.024 1.15 1.006 curveto 0.431 0.889 0.032 0.495
0 -0.074 curveto -0.036 -0.478 0.126 -0.844 0.285 -1.201 curveto 0.135 -1.316 0.05 -1.642 0.102
-1.949 curveto 0.19 -2.464 0.536 -2.778 1.138 -2.89 curveto 1.377 -2.935 1.995 -2.974 1.995 -2.945
curveto 1.995 -2.936 1.927 -2.845 1.842 -2.744 curveto 1.501 -2.348 1.223 -1.907 0.984 -1.445 curveto
1.131 -1.366 1.501 -1.197 1.98 -1.188 lineto 2.179 -1.182 curveto 2.166 -0.993 2.149 -0.805 2.128
-0.617 curveto 1.53 -0.584 1.134 -0.729 0.766 -0.872 curveto 0.562 -0.321 0.686 0.326 0.918 0.58
curveto 1.243 0.937 1.932 0.919 2.282 0.555 curveto 2.36 0.46 2.364 0.424 2.364 0.424 curveto
1.87 0.604 1.405 0.378 1.339 0.117 curveto 1.254 -0.223 1.722 -0.49 2.266 -0.377 curveto 2.496
-0.32 2.662 -0.13 2.659 0.07 curveto 2.66 0.663 2.166 1.044 1.463 1.035 closepath moveto 0.598
-1.736 curveto 0.823 -2.087 1.334 -2.5 1.669 -2.77 curveto 0.442 -2.756 0.445 -1.851 0.598 -1.736
closepath

)

% generated by running: python bin/svg2lypath.py assets/express-f-int4-w.svg 3.98 0 -0.74 -p1
express-clef-f-orig = #'(
moveto 2.033 0.261 curveto 2.225 0.253 2.404 0.212 2.437 0.067 curveto 2.438 -0.076 2.268 -0.16
2.081 -0.171 curveto 1.913 -0.188 1.549 -0.159 1.5 0.024 curveto 1.461 0.173 1.757 0.272 2.033
0.261 closepath

)

expressFClefPianoforte = #(make-path-stencil express-clef-f 0.0 clef-factor clef-factor #t)
expressFClefOriginal = #(make-path-stencil (append express-clef-f express-clef-f-orig) 0.0 clef-factor clef-factor #t)


% generated by running: python bin/svg2lypath.py assets/express-d-int4-w.svg 3.8 0 -0.5 -p0
express-clef-d = #'(
moveto 0.126 1.9 curveto 0.441 1.505 0.933 0.704 0.959 0.63 curveto 0.263 0.672 -0.05 -0.07
0 -0.405 curveto 0.071 -0.869 0.882 -0.644 1.158 -0.085 curveto 1.262 0.129 1.257 0.28 1.117
1.032 curveto 1.092 1.194 1.05 1.33 0.997 1.613 curveto 1.774 1.438 2.203 0.358 1.912 -0.641
curveto 1.869 -0.788 1.418 -1.991 0.909 -1.154 curveto 0.63 -1.394 0.384 -1.673 0.105 -1.9 curveto
0.86 -1.911 1.411 -1.801 1.981 -1.439 curveto 2.921 -0.816 2.937 0.76 2.011 1.445 curveto 1.576
1.765 0.863 1.95 0.126 1.9 closepath

)

% generated by running: python bin/svg2lypath.py assets/express-d-int4-w.svg 3.8 0 -0.5 -p1
express-clef-d-orig = #'(
moveto 0.824 0.356 curveto 0.876 0.355 0.921 0.341 0.955 0.313 curveto 1.038 0.242 0.961 0.029
0.87 -0.095 curveto 0.709 -0.314 0.484 -0.486 0.245 -0.432 curveto 0.059 -0.389 0.237 -0.039 0.457
0.188 curveto 0.565 0.299 0.709 0.359 0.824 0.356 closepath

)

expressDClefPianoforte = #(make-path-stencil express-clef-d 0.0 clef-factor clef-factor #t)
expressDClefOriginal = #(make-path-stencil (append express-clef-d express-clef-d-orig) 0.0 clef-factor clef-factor #t)

% generated by running: bin/svg2lypath.py assets/pianoroll.svg 5
pianoroll = 
#(ly:make-stencil
  `(path 0.001
     (
moveto 0.021 4.976 curveto 0.014 4.961 0.004 4.65 0.006 4.242 lineto 0.01 3.499 curveto 0.471
3.503 0.932 3.508 1.394 3.513 lineto 1.394 3.834 lineto 0.198 3.834 lineto 0.198 4.067 lineto
1.396 4.067 curveto 1.391 4.176 1.385 4.286 1.38 4.395 lineto 0.198 4.384 lineto 0.198 4.679
lineto 1.394 4.679 lineto 1.394 5 lineto 0.844 5 curveto 0.021 5 0.046 5.011 0.021
4.976 closepath moveto 0.006 2.92 curveto -0.002 2.899 -0.004 2.692 0 2.461 lineto 0.01 2.041
curveto 0.471 2.045 0.932 2.05 1.394 2.055 lineto 1.394 2.376 lineto 0.198 2.376 lineto 0.198
2.642 curveto 0.592 2.639 0.986 2.633 1.38 2.628 lineto 1.396 2.959 lineto 0.71 2.959 curveto
0.165 2.959 0.017 2.951 0.006 2.92 closepath moveto 0.004 0.75 lineto 0.004 0 curveto 0.463
0.002 0.921 0.006 1.38 0.01 curveto 1.385 0.118 1.391 0.226 1.396 0.334 lineto 0.198 0.334
lineto 0.198 0.597 lineto 1.394 0.597 lineto 1.394 0.918 lineto 0.198 0.918 lineto 0.198 1.182
lineto 1.38 1.174 lineto 1.396 1.501 lineto 0.006 1.501 closepath

)
     round round #t)
   (cons 0 1.7)
   (cons 2.4 2.6))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTEHEADS

% the default notehead width.
% note: do not make this any bigger, as it causes note unification to fail. See comment below.
#(define notehead-width 1.3)

% when creating a notehead stencil, we center and scale it so all noteheads have EXACTLY the same width.
% Otherwise, note unification may fail (you will see duplicate noteheads). 
% This happens when different nothead glyphs are unified (e.g. white and black noteheads).
% Example:
% r8 <ef g>4 | % right hand, staff=1
% d8 \stemDown \change Staff = "1" <ef g>8 | % left hand. <ef g>8 should be unified with <ef g>4 above
#(define (create-notehead-scaled path scaleX scaleY)
  (let* (
          (stencil (make-path-stencil path 0.0 1 1 #t))
          (stencil-width (stencil-size stencil X))
          (factor (/ notehead-width stencil-width))
          (stencil (ly:stencil-scale stencil (* factor scaleX) (* factor scaleY)))
        )
    (center-glyph stencil)
))

#(define (create-notehead path)
  (create-notehead-scaled path 1 1))

% generated by running: bin/svg2lypath.py assets/note-white-classic.svg -1.2 -0.5 -0.5
#(define white-straight-classic (create-notehead '(
moveto -0.577 -0.356 curveto -0.619 -0.281 -0.61 -0.19 -0.6 -0.107 curveto -0.565 0.074 -0.479 0.255
-0.325 0.365 curveto -0.189 0.467 -0.012 0.488 0.154 0.483 curveto 0.277 0.484 0.408 0.473 0.511
0.399 curveto 0.601 0.332 0.611 0.21 0.6 0.107 curveto 0.589 -0.043 0.528 -0.193 0.415 -0.296
curveto 0.28 -0.424 0.091 -0.477 -0.092 -0.483 curveto -0.223 -0.484 -0.362 -0.492 -0.485 -0.436 curveto
-0.522 -0.417 -0.555 -0.391 -0.577 -0.356 closepath moveto -0.46 -0.28 curveto -0.403 -0.324 -0.327 -0.316
-0.259 -0.314 curveto -0.088 -0.302 0.07 -0.224 0.208 -0.126 curveto 0.309 -0.056 0.412 0.024 0.465
0.137 curveto 0.49 0.191 0.483 0.272 0.42 0.295 curveto 0.316 0.334 0.202 0.307 0.1 0.274
curveto -0.076 0.206 -0.239 0.106 -0.383 -0.015 curveto -0.448 -0.071 -0.51 -0.158 -0.479 -0.248 curveto
-0.474 -0.257 -0.471 -0.279 -0.46 -0.28 closepath

)))


% generated by running: bin/svg2lypath.py assets/note-white-diag-classic.svg -1.2 -0.5 -0.5
#(define white-diag-classic (create-notehead '(
moveto -0.576 -0.378 curveto -0.618 -0.301 -0.608 -0.208 -0.6 -0.123 curveto -0.574 0.026 -0.517 0.174
-0.418 0.291 curveto -0.319 0.409 -0.175 0.484 -0.023 0.502 curveto 0.068 0.514 0.16 0.513 0.251
0.508 curveto 0.369 0.497 0.503 0.469 0.576 0.366 curveto 0.641 0.255 0.623 0.118 0.6 -0.003
curveto 0.557 -0.216 0.393 -0.394 0.19 -0.465 curveto 0.026 -0.522 -0.151 -0.523 -0.322 -0.508 curveto
-0.417 -0.493 -0.523 -0.466 -0.576 -0.378 closepath moveto -0.434 -0.37 curveto -0.369 -0.438 -0.267 -0.423
-0.185 -0.404 curveto -0.012 -0.369 0.141 -0.267 0.264 -0.143 curveto 0.365 -0.045 0.449 0.076 0.482
0.214 curveto 0.499 0.277 0.479 0.356 0.416 0.385 curveto 0.307 0.43 0.188 0.385 0.085 0.342
curveto -0.059 0.276 -0.189 0.178 -0.299 0.064 curveto -0.377 -0.024 -0.469 -0.119 -0.479 -0.243 curveto
-0.479 -0.287 -0.469 -0.342 -0.434 -0.37 closepath

)))

% generated by running: bin/svg2lypath.py assets/note-black-classic.svg -1.2 -0.5 -0.5
#(define black-straight-classic (create-notehead '(
moveto -0.571 -0.002 curveto -0.51 0.165 -0.36 0.281 -0.203 0.351 curveto -0.031 0.429 0.167 0.456
0.351 0.411 curveto 0.466 0.381 0.581 0.297 0.6 0.173 curveto 0.618 0.071 0.573 -0.03 0.521
-0.115 curveto 0.422 -0.264 0.257 -0.355 0.09 -0.411 curveto -0.08 -0.463 -0.275 -0.476 -0.438 -0.393
curveto -0.529 -0.348 -0.599 -0.258 -0.6 -0.155 curveto -0.603 -0.102 -0.591 -0.05 -0.571 -0.002 closepath

)))

% generated by running: bin/svg2lypath.py assets/note-black-diag-classic.svg -1.2 -0.5 -0.5
#(define black-diag-classic (create-notehead '(
moveto 0.181 0.499 curveto 0.513 0.497 0.607 0.268 0.6 0.134 curveto 0.596 0.043 0.556 -0.044
0.51 -0.121 curveto 0.375 -0.33 0.096 -0.496 -0.169 -0.499 curveto -0.252 -0.5 -0.334 -0.486 -0.411
-0.453 curveto -0.53 -0.4 -0.602 -0.27 -0.6 -0.141 curveto -0.616 0.109 -0.253 0.502 0.181 0.499
closepath

)))

% generated by running: bin/svg2lypath.py assets/minim-lines.svg -1.77 -0.5 -0.5
#(define minim-lines (create-notehead-scaled  '(
moveto 0.687 -0.157 lineto 0.759 0.482 lineto 0.885 0.482 lineto 0.885 -0.482 lineto 0.759 -0.482
closepath moveto -0.759 -0.482 lineto -0.885 -0.482 lineto -0.885 0.482 lineto -0.759 0.482 lineto -0.687
0.205 closepath

) (/ 1.77 1.2) (/ 1.77 1.2)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% custom Express Stave clefs


% Save the original clef function to avoid infinite recursion
#(define original-clef clef)

#(add-new-clef "express-treble" "clefs.G" -3 0 -11)
#(add-new-clef "express-alto" "clefs.C" 0 0 -2)
#(add-new-clef "express-bass" "clefs.F" 3 0 7)

% overriding the clef function
clef =
#(define-music-function (type) (string?)
  (let (
          (name (cond
            ((string=? type "treble") "express-treble")
            ((string=? type "alto")   "express-alto")
             ((string=? type "bass")   "express-bass")
            (else type)))
      )
   (original-clef name)

))

#(define (clef-stencil-callback grob default)
  (let* 
    (
      (glyph (ly:grob-property grob 'glyph))
      (change? (string-suffix? "_change" (ly:grob-property grob 'glyph-name)))
      (stencil (cond
          ((string=? glyph "clefs.G") (if (= express-pianoforte 1) expressBClefPianoforte expressBClefOriginal))
          ((string=? glyph "clefs.F") (if (= express-pianoforte 1) expressFClefPianoforte expressFClefOriginal))
          ((string=? glyph "clefs.C") (if (= express-pianoforte 1) expressDClefPianoforte expressDClefOriginal))
          (else #f)))

      ; change clefs are smaller
      (stencil (cond
          ((and stencil change?) (ly:stencil-scale stencil 0.85 0.85))
          ((not stencil) default)
          (else stencil)))
    )
  
  stencil
))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% replacing ottava with one that supports chromatic shift

#(define original-ottava ottava)
#(set-object-property! 'originalC 'translation-type? number?)

ottava =
#(define-music-function (s) (integer?)
   #{
     % 1. Capture the current middleCPosition before \ottava runs
     \context Staff \applyContext
     #(lambda (ctx)
        (let* ((base (ly:context-property ctx 'originalC #f)))
         ;(display "STARTING: ")(display s)(display ", base: ")(display base)(newline)
          (if (not (number? base))
            (begin
            ;(display "Setting base to: ")(display (ly:context-property ctx 'middleCPosition))(newline)
            (ly:context-set-property! ctx 'originalC 
              (ly:context-property ctx 'middleCPosition)))
          )
        )
      )
     
     % 2. Run the built-in \ottava to get the visual bracket/text
     \original-ottava #s
     
     % 3. Apply the chromatic shift logic
     \context Staff \applyContext
     #(lambda (ctx)
        (let ((c (ly:context-property ctx 'originalC)))
        ;(display "s: ")(display s)(display ", c: ")(display c)(newline)
        (if (number? c) (ly:context-set-property! ctx 'middleCPosition (- c (* s 12))))
          (if (zero? s)
            (ly:context-set-property! ctx 'originalC #f)
          )
        )
      )
   #})


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOM NOTE HEADS

% noteheads appear differently according to

#(define (esNoteHeads)
  (let* (
    (shape-base-straight 0)
    (shape-base-diag 1)
    (shape-sec-straight 2)
    (shape-sec-diag 3)

    (shape-type-map ; mapping note -> shape
      '((0 . shape-base-diag)
        (1 . shape-sec-straight)
        (2 . shape-base-diag)
        (3 . shape-sec-straight)
        (4 . shape-base-diag)
        (5 . shape-base-straight)
        (6 . shape-sec-straight)
        (7 . shape-base-straight)
        (8 . shape-sec-diag)
        (9 . shape-base-straight)
        (10 . shape-sec-straight)
        (11 . shape-base-straight)))
  )
  (lambda (grob)
	(let* 
    (
      (fsz  (ly:grob-property grob 'font-size 0.0))
      (mult (magstep fsz))
      (ptch (ly:event-property (event-cause grob) 'pitch))
      (semi (ly:pitch-semitones ptch))
      (note-shape (modulo semi 12))

      (dur (ly:event-property (event-cause grob) 'duration))
      (dur-log (ly:duration-log dur))
      
      (note-style 'classic)
      (note-duration (if (<= dur-log 1) 'long 'regular))
      
      (color-base (if (= express-pianoforte 0) 'white 'black))
      (color-sec (if (= express-pianoforte 0) 'black 'white))
      
      (shape-type (assoc-get note-shape shape-type-map))

      (note-color (case shape-type 
        ((shape-base-straight shape-base-diag) color-base)
        (else color-sec)))

      (note-direction (case shape-type 
        ((shape-base-straight shape-sec-straight) 'straight)
        (else 'diag)))

      (staff-thickness (ly:staff-symbol-line-thickness grob))
      
      (notehead (ly:stencil-scale
        (get-notehead note-style note-color note-direction note-duration)
        mult mult)
      )

      ; this is the regular length note: without the minim decoration.
      ; it's useful since we want know the notehead's height on its own
      (notehead-regular (ly:stencil-scale
        (get-notehead note-style note-color note-direction 'regular)
        mult mult)
      )

      ; calculate the note shift:
      (y-translate (let* (
          (y-extent (ly:stencil-extent notehead-regular Y))
          (y-min (car y-extent))
          (y-max (cdr y-extent))
          (note-height (- y-max y-min))

          ; translate-up is the translation value required to place the top edge of the notehead
          ; against the staff line two semitones above the current note
          (translate-up (+ (* 2 0.5  express-staff-space) ; the base poisition is 2 semitones up
            (* -0.5 note-height) ; reducing half the notehead height
            (* -0.5 staff-thickness) ; reducing half the notehead thickness
            0.02)) ; a slight nudge towards the staff line since there's sometimes a very small gap

          ; translate-up-ext places the notehead slightly above the staff line above
          (translate-up-ext (+ (* 1 0.5  express-staff-space) ; the base poisition is 1 semitones up
            (* -0.37 note-height) ; reducing less than half the notehead height so there will be a slight protrusion
            (* 0.5 staff-thickness) ; adding half the notehead thickness (so the base alignment is to the stall line's top)
            0)) ; a slight nudge towards the staff line since there's sometimes a very small gap
        )
        
        ; for each note position, we decide to which direction (if any) to translate
        
        (case note-shape
          ; C, K(F#), I(C#), G: going up
          ((0 6) translate-up)

          ((1 7) translate-up-ext)
          ; J(D#) E, A, H(A#): going down
          ((4 10) (* -1 translate-up))
          ((3 9) (* -1 translate-up-ext))
          ; D, F, L(G#), B: stay in the middle
          (else 0)
        )
      ))

      (notehead-shifted (ly:stencil-translate notehead (cons 0 y-translate)))
      
    )
    notehead-shifted   
	) ; let
)))

% for a given glyph input, generates a definition for  noteheads according to their duration (regular and long).
% note that for long noteheads, we scale the minim-lines glyph to perfrectly fit the height of the 
% regular notehead.
% this function (correctly) assumes that both the glyph and the minim-lines glyphs are centered around 0
#(define (generate-noteheads-lengths glyph)
  (let* (
          (glyph-width (stencil-size glyph X))
          (glyph-height (stencil-size glyph Y))

          (lines-width (stencil-size minim-lines X))
          (lines-height (stencil-size minim-lines Y))

          (scale-y-factor (if (> lines-height 0) 
                            (/ glyph-height lines-height) 
                            1))

          (scaled-lines (ly:stencil-scale minim-lines 1 scale-y-factor))
  )
   `((regular . ,(ly:stencil-translate glyph (cons (/ glyph-width 2) 0)))
     (long . ,(if (> express-multi-stems 0)
                  (ly:stencil-translate glyph (cons (/ glyph-width 2) 0))
                  (ly:stencil-translate 
                    (ly:stencil-add glyph scaled-lines)
                    ; note: we're reducing 0.07 since it looks better when notes are shifted due to
                    ; a notehead collision. Not sure why this adjustment is required
                    (cons (-(/ lines-width 2) 0.07) 0) ))

    ))
)) 

% definitions of all notehead types: style (classic), color (black/white), direction (straight/diag), duration (regular/long)
#(define notehead-styles
  `((classic . (
      (white . (
        (straight . ,(generate-noteheads-lengths white-straight-classic))
        (diag . ,(generate-noteheads-lengths white-diag-classic))
      ))
      (black . (
        (straight . ,(generate-noteheads-lengths black-straight-classic))
        (diag . ,(generate-noteheads-lengths black-diag-classic))
      ))
    ))
))


#(define (get-notehead style color direction duration)
  (let* (
    ;(x (debug D-ALL "style: ~a, color: ~a, direction: ~a, duration: ~a" style color direction len))
    (style-data (assoc-get style notehead-styles))
    (color-data (assoc-get color style-data))
    (direction-data (assoc-get direction color-data))
    )
    (assoc-get duration direction-data)
))

%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE SHIFTS (CROSS-STEM)
      
%%%% For chords and intervals, shifts note heads to left or right of stem according to the offsets array
#(define ((shift-notes offsets) grob)
"Defines how NoteHeads should be moved according to the given list of offsets."
 (let* (
 ;; NoteHeads
        ;; Get the NoteHeads of the NoteColumn
        (note-heads (ly:grob-array->list (ly:grob-object grob 'note-heads)))
        ;; Get their durations
        (nh-duration-log 
          (map 
            (lambda (note-head-grobs)
              (ly:grob-property note-head-grobs 'duration-log))
            note-heads))
        ;; Get the stencils of the NoteHeads
        (nh-stencils 
          (map 
            (lambda (note-head-grobs)
              (ly:grob-property note-head-grobs 'stencil))
            note-heads))
        ;; Get their length in X-axis-direction
        (stencils-x-lengths 
          (map 
            (lambda (x) 
                (let* ((stencil (ly:grob-property x 'stencil))
                       (stencil-X-exts (ly:stencil-extent stencil X))
                       (stencil-lengths (interval-length stencil-X-exts)))
                stencil-lengths))
             note-heads))
 ;; Stem
        (stem (ly:grob-object grob 'stem))
        (stem-thick (ly:grob-property stem 'thickness 1.3))
        (stem-x-width (/ stem-thick 10))      
        (stem-dir (ly:grob-property stem 'direction))
        
        ;; stencil width method, doesn't work with non-default beams
        ;; so using thickness property above instead
        ;; (stem-stil (ly:grob-property stem 'stencil))
        ;; (stem-x-width (if (ly:stencil? stem-stil)
        ;;                 (interval-length (ly:stencil-extent stem-stil X))
        ;;                 ;; if no stem-stencil use 'thickness-property
        ;;                 (/ stem-thick 10)))
        
        ;; Calculate a value to compensate the stem-extension
        (stem-x-corr 
          (map 
            (lambda (q)
               ;; TODO better coding if (<= log 0)
               (cond ((and (= q 0) (= stem-dir 1))
                      (* -1 (+ 2  (* -4 stem-x-width))))
                     ((and (< q 0) (= stem-dir 1))
                      (* -1 (+ 2  (* -1 stem-x-width))))
                     ((< q 0)
                      (* 2 stem-x-width))
                     (else (/ stem-x-width 2))))
             nh-duration-log)))
   
   ;; (display offsets) (display " - offsets") (newline)
   
 ;; Final Calculation for moving the NoteHeads   
   (for-each
     (lambda (nh nh-x-length off x-corr) 
         (if (= off 0)
           #f 
           (ly:grob-translate-axis! nh (* off (- nh-x-length x-corr)) X)))
     note-heads stencils-x-lengths offsets stem-x-corr)
))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOTS REPOSITIONING

% checks if a certain grob is a notehead (or something else, e.g. a rest)
#(define (is-notehead? grob)
  (let* ((meta (ly:grob-property grob 'meta))
         (name (assoc-get 'name meta)))
    (eq? name 'NoteHead)))

% the shortest delta between value and a base. E.g. 
% (base-delta -0.1 3) = -0.1
% (base-delta 3.2 3) = 0.2
% (base-delta 2.9 3) = -0.1
#(define (base-delta value base)
  (let* ((m (floor-remainder value base)))
    (if (> m (/ base 2))
      (- m base)
      m)))

% check if a stem has a flag: 𝅘𝅥𝅯
#(define (has-flag? stem)
   (let ((flag (ly:grob-object stem 'flag)))
     (and (ly:grob? flag)
          (memq 'flag-interface (ly:grob-interfaces flag)))))

% calculates the y-offset of dots for beamed stems, so they will not overlap the beam
#(define (beam-y-offset stem-grob beam-grob stem-dir x-offset)
  (let* (
        ; calculate the beam's slope:
        (y-pos (ly:grob-property beam-grob 'positions))
        (y-left (car y-pos))
        (y-right (cdr y-pos))

        (x-pos (ly:grob-property beam-grob 'X-positions))
        (x-left (car x-pos))
        (x-right (cdr x-pos))

        (slope (if (= x-right x-left 0) 
          0
          (/ (- y-right y-left) (- x-right x-left))
        ))

        (y-offset-base (* slope x-offset)) ; the base offset, based on the beam's slope and the x-offset from the stem

        ; additional offset due to the beams' count and thickness
        (thickness (ly:grob-property beam-grob 'beam-thickness))
        (gap (ly:grob-property beam-grob 'gap))
        (beaming (ly:grob-property stem-grob 'beaming))
        (num-beams (if (list? beaming)
            (length (filter number? beaming))
            0
        ))

        (extra-gap (* 3 (- gap thickness)))

        (thickness-offset (+ thickness extra-gap (* (- num-beams 1) 1.13 gap)))
        
        (y-offset (+ y-offset-base (* -1 stem-dir thickness-offset)))
  )

  ;(debug D-ALL "beam-y-offset. slope: ~a, y-offset-base: ~a, thickness: ~a, gap: ~a, num-beams: ~a" slope y-offset-base thickness gap num-beams)
  y-offset
  
))


% if dots are unified, hide all dots but the first, which will be moved to the stem's side (instead of the notehead's side)
#(define (dots-shift-to-stem-tip dots-grob)
    (let* (
          (parent (ly:grob-parent dots-grob Y)) ; can be a notehead, or something else (e.g. a rest)
          (stem (ly:grob-object parent 'stem))
         )
      (if (and unify-dots? (ly:grob? stem) (is-notehead? parent))
          (let* (
                  (note-head parent)
                  (note-col (ly:grob-parent note-head X))
                  (note-heads (ly:grob-object note-col 'note-heads))
                  (first-notehead (ly:grob-array-ref note-heads 0))
                  
                )
            (if (eq? first-notehead note-head)
              (let* (
                        (dot-col (ly:grob-parent dots-grob X))
                        (system (ly:grob-system dots-grob))

                        ; the delta required to move from our position to the stem center (in both x and y axis):
                        (dots-stem-x-delta (/ (-   
                            (ly:grob-relative-coordinate dots-grob system X)
                            (ly:grob-relative-coordinate stem system X)
                        ) express-staff-space))

                        (dots-stem-y-delta (/ (-
                            (ly:grob-relative-coordinate stem system Y)
                            (ly:grob-relative-coordinate dots-grob system Y)
                        ) express-staff-space))

                        (stem-y-ext (ly:grob-extent stem stem Y))
                        (stem-x-ext (ly:grob-extent stem stem X))
                        
                        (stem-dir (ly:grob-property stem 'direction))
                        (up-stem? (= stem-dir UP))
                        
                        ;; If stem is UP (1), tip is the max extent (cdr)
                        ;; If stem is DOWN (-1), tip is the min extent (car)                        
                        (tip-y (if up-stem? (cdr stem-y-ext) (car stem-y-ext)))
                                              
                        (dots-half-height (* (extent-size (ly:grob-extent dots-grob dots-grob Y)) 0.8))
                        (dot-height-shift (* -1 stem-dir dots-half-height))

                        ; the amount we need to shift the dots to the stem tip
                        (shift-tip-y (+ dots-stem-y-delta dot-height-shift (/ tip-y express-staff-space)))
                        (shift-tip-x (+ (- dots-stem-x-delta) (cdr stem-x-ext)))

                        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        (grob-pad (ly:grob-property dot-col 'padding))

                        (flag-offset (if (has-flag? stem) 0.7 0)) ; stems with flags 𝅘𝅥𝅯 get an extra offset
                        (offset-x (+ grob-pad flag-offset))
                        

                        (beam-grob (ly:grob-object stem 'beam))
                        (has-beam (if (ly:grob? beam-grob) #t #f))
                        (dots-extent-right (cdr (ly:grob-extent dots-grob dots-grob X)))
                        (beam-offset (if has-beam
                            (beam-y-offset stem beam-grob stem-dir (+ offset-x dots-extent-right)) 
                            0))

                        (offset-y beam-offset)
                        
                        (shift-x (+ shift-tip-x offset-x))
                        (shift-y (+ shift-tip-y offset-y))

                        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                        ; if the dots are position over a staff line, we need to shift them so they will not be hidden

                        (staff-symbol (ly:grob-object dots-grob 'staff-symbol))
                        (dots-staff-y-delta (/ (-   
                            (ly:grob-relative-coordinate dots-grob system Y)
                            (ly:grob-relative-coordinate staff-symbol system Y) 
                        ) express-staff-space))

                        (dots-staff-y-delta (+ dots-staff-y-delta shift-y))

                        ; the translated dots y distance from the closest staff line. we take the remainder 
                        ; from a value of 3 since the staff lines are distributed each 6 semi-tones (3 tones) apart
                        (line-delta (base-delta dots-staff-y-delta 3))
                        (is-near-staff (< (abs dots-staff-y-delta) 4.5))
                        (line-thickness (ly:staff-symbol-line-thickness staff-symbol))

                        (min-staffline-distance (+ (* line-thickness 0.5) (* 1.5 dots-half-height)))
                        (staffline-collision-offset 
                          (if (and is-near-staff (< (abs line-delta) min-staffline-distance))
                            (+ (* min-staffline-distance stem-dir) line-delta)
                            0
                        ))

                        (shift-y (- shift-y staffline-collision-offset))
                    )
                (ly:grob-set-property! dots-grob 'extra-offset (cons shift-x shift-y))
                ;(debug D-ALL "SHOW. stem-length: ~a" (ly:grob-property stem 'length))
                #f
              )
              #t ; this is not the first notehead - hide the dots
            )
          )
          #f  ; no work is required for this dot type
      )
  
    )
)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOUBLE STEMS
% this section of code is based on the clairnote.ly code by Paul Morris, but modified to work with express-stave
% See: https://gitlab.com/paulmorris/lilypond-clairnote

#(define (cn-note-heads-from-grob grob default)
   ;; Takes a grob like a Stem and returns a list of
   ;; NoteHead grobs or default.
   (let* ((heads-array (ly:grob-object grob 'note-heads))
          (heads-list (if (ly:grob-array? heads-array)
                          (ly:grob-array->list heads-array)
                          ;; should never/rarely? happen:
                          default)))
     heads-list))


#(define (cn-grob-edge grob positive)
   ;; Takes a grob and returns the edge of the grob in positive
   ;; or negative direction (up or down), positive arg is boolean.
   (let* ((offset (ly:grob-property grob 'Y-offset))
          (extent (ly:grob-property grob 'Y-extent))
          (extent-dir (if positive (cdr extent) (car extent))))
     (+ offset extent-dir)))

#(define (cn-grobs-edge grobs positive)
   ;; Takes a list of grobs and positive, a boolean of whether the
   ;; direction we care about is positive/up or not/down, and returns
   ;; the furthest edge of the grobs in that direction.
   (let* ((comparator (if positive > <))
          (final-edge
           (fold (lambda (g prev-edge)
                   (let ((this-edge (cn-grob-edge g positive)))
                     (if (comparator this-edge prev-edge)
                         this-edge
                         prev-edge)))
                 (cn-grob-edge (car grobs) positive)
                 (cdr grobs))))
     final-edge))


#(define (cn-multi-stem grob duration-log)
   (let*
    ((stem-stil (ly:stem::print grob))
     (dir (ly:grob-property grob 'direction))
     (up-stem (= 1 dir))
     (stem-thickness (ly:grob-property grob 'thickness))

     ;; --- X / width / spacing ---

     (stem-x-extent (ly:grob-property grob 'X-extent))
     (stem-width (abs (- (car stem-x-extent) (cdr stem-x-extent))))

     (spacing-scale (ly:grob-property grob 'cn-double-stem-spacing 2.2))
     (spacing-shift (* dir spacing-scale stem-width))
     (stem-y-extent (ly:grob-property grob 'Y-extent))

     (note-heads (cn-note-heads-from-grob grob '()))
     (heads-edge (cn-grobs-edge note-heads up-stem))
     (stem-tip (if up-stem (cdr stem-y-extent) (car stem-y-extent)))
     
     (stem2-y-extent (if up-stem
                         (cons heads-edge stem-tip)
                         (cons stem-tip heads-edge)))

     (stem-height (abs (- (car stem-y-extent) (cdr stem-y-extent))))
     (stem2-height (abs (- (car stem2-y-extent) (cdr stem2-y-extent))))

     (height-ratio (* (/ stem2-height stem-height) 0.9))
     (stem-y-translate (if up-stem 
        (- (max (car stem-y-extent) (cdr stem-y-extent)))
        (- (min (car stem-y-extent) (cdr stem-y-extent)))
     ))
  
     (stem-single 
        (ly:stencil-translate-axis
            (ly:stencil-scale 
                (ly:stencil-translate-axis stem-stil
                  stem-y-translate Y)
              1 height-ratio)
          (- stem-y-translate) Y)
     )
     (shift-count 1)
     (total-shifts (- 2 duration-log))
    )

    (while (<= duration-log 1)
      (let* (
          (shift (* shift-count spacing-shift))
          (stem2-stil (ly:stencil-translate-axis stem-single shift X))
        )
        (set! duration-log (+ duration-log 1))
        (set! shift-count (+ shift-count 1))
        (set! stem-stil (ly:stencil-add stem-stil stem2-stil))
      )
    )

    (let (
        (x-extent (ly:stencil-extent (ly:grob-property grob 'stencil) X))
        (x-margin (/ (* spacing-shift total-shifts) express-staff-space))
      )

      (ly:grob-set-property! grob 'stencil stem-stil)
      ;; X-extent needs to be set here because its usual callback
      ;; ly:stem::width doesn't take the actual stencil width into account

      (ly:grob-set-property! grob 'X-extent
                            (cons 
                                (+ (car x-extent)(if up-stem 0 x-margin))
                                (+ (cdr x-extent) (if up-stem x-margin 0) )))

    )))

#(define (stem-before-line-breaking)
   ;; Lengthen all stems to undo staff compression side effects,
   ;; and give half notes double stems.
   (lambda (grob)

      ;; Make sure omit is not in effect (i.e. stencil is not #f)
      ;; and the stem has a notehead (i.e. is not for a rest,
      ;; rest grobs have stem grobs that have no stencil)
     (when (and 
                (> express-multi-stems 0)
                (ly:grob-property-data grob 'stencil)
                (not (null? (ly:grob-object grob 'note-heads)))) (let* (

          (duration-log (ly:grob-property grob 'duration-log))
      )
        ;; double stems for half notes: tricking the system by specifying duration-log = 1 (half note)
        (when (and (number? duration-log) (< duration-log 1))
          (ly:grob-set-property! grob 'duration-log 1))

        (when (>= 1 duration-log) 
          (ly:grob-set-property! grob 'thickness 1.3)
          (cn-multi-stem grob duration-log))
     ))
))

%%%%%%%%%%%%%%%%%%%%%%%
% STAFF DEFINITIONS
% each staff type gets its own set of overrides, etc.

#(define thick-staffline 1)


% override grace appearance, and make it slightly bigger. Couldn't find a simple definition. 
% There is an elegant way to define using: 
%   $(add-grace-property 'Voice 'NoteHead 'font-size 2)
% but setting things like that seems to be overridden by other definitions
% The approach below is ugly but working, as described here:
% https://music.stackexchange.com/questions/101066/changing-the-size-of-all-grace-notes-with-lilypond

esGraceOn = {
  \override NoteHead.font-size = #-2
  \override Stem.length = #7
}

esGraceOff = {
  \revert NoteHead.font-size
  \revert Stem.length
}

startGraceMusic = { 
  \esGraceOn 
}
stopGraceMusic = {
  \esGraceOff
}

startSlashedGraceMusic = { 
  \esGraceOn 
  \override Flag.stroke-style = #"grace"
}
stopSlashedGraceMusic = {
  \esGraceOff
  \revert Flag.stroke-style
}

startAppoggiaturaMusic = { 
  <>(
  \esGraceOn
}
stopAppoggiaturaMusic = {
  \esGraceOff
  <>)
}

startAcciaccaturaMusic = { 
  <>(
  \esGraceOn
  \override Flag.stroke-style = #"grace"
}
stopAcciaccaturaMusic = {
  \esGraceOff
  \revert Flag.stroke-style
  <>)
}




\paper {
  % #(layout-set-staff-size 16) % general staff size
  #(if (= express-showpianoroll 1)
        ; removing indents so the pianoroll appears next to the staff
       (begin
         (set! indent (* 0 mm))
         (set! short-indent (* 0 mm))))
}


\header {
    tagline = \markup \center-column \tiny {
      \center-column {
        \line { Music engraving by LilyPond #(lilypond-version) — \with-url "https://lilypond.org/" "www.lilypond.org"}
        \line { Express Stave for LilyPond #ES_VERSION — \with-url "https://github.com/mortisusu/express-stave-lilypond/" "github.com/mortisusu/express-stave-lilypond"}
      }
    
  }
}

\layout { 
    \context {
      \Score
      #(if (= express-showpianoroll 1)
       #{
        % moving the bar numbers so they won't collide with the pianoroll stencil
      \override BarNumber.extra-offset = #'(2 . 0)
      #})

      #(if (= thick-staffline 1)
      #{
        \override BarNumber.Y-offset = #(* 6 express-staff-space) % compensating for thicker staff lines (which causes the position to be wrong)
      #}
      #{ #}
      )
      
      \override StaffGrouper.staff-staff-spacing.padding = 0.5
      \override Hairpin.height = #(/ 0.6 express-staff-space) % crescendo, decrescendo height. default is 0.6666
      \override Flag.stencil = % making flags slightly shorter
          #(grob-transformer 'stencil 
            (lambda (grob original)
              (ly:stencil-scale original 1.0 0.8)))

    }


  \context {
    \Voice
    \override Rest.Y-offset =
      #(lambda (grob)
         (let ((dir (ly:grob-property grob 'direction))
               (shift (* express-staff-space 3)))
           (cond
             ((and (number? dir) (= dir UP)) shift)
             ((and (number? dir) (= dir DOWN)) (- shift))
             (else 0))))

    \override MultiMeasureRest.Y-offset =
      #(lambda (grob)
         (let ((dir (ly:grob-property grob 'direction))
               (shift (* express-staff-space 2)))
           (cond
             ((and (number? dir) (= dir UP)) shift)
             ((and (number? dir) (= dir DOWN)) (- shift))
             (else 0))))
  }
 
  \context {
    \Staff
    staffLineLayoutFunction = #ly:pitch-semitones    
    \override StaffSymbol.line-positions = #'( -6 0 6 )
    % \override StaffSymbol.line-positions = #'( -6 -5 -4 -3 -2 -1  -0.1 0 0.1 1 2 3 4 5 6 ) ; used for debugging
    \override StaffSymbol.ledger-positions = #'(-6 0 6)
    \override StaffSymbol.ledger-extra = #1.6
    % \override Stem.no-stem-extend = ##t
    \override NoteHead.stencil = #(esNoteHeads)

    \override Clef.stencil = #(grob-transformer 'stencil clef-stencil-callback)

    \override Stem.length-fraction = #(/ 0.9 express-staff-space)  % the relative stem leangth (default is 1)
    % \override Stem.length = #(/ 8.0 express-staff-space)
    % \override Stem.details.beamed-lengths = #(map (lambda (x) (* x 1.2)) '(3.26 3.5 3.6))
    \override Stem.thickness = #0.87  % Default is 1.3; lower is thinner
    \override StaffSymbol.staff-space = #express-staff-space

    \override Beam.beam-thickness = #0.65  % Default is 0.48
    \override Beam.length-fraction = #1.2 % the relative distance between beams lines (e.g. in 16th note). Default is 1.

    % since we are using a chromatic scale, we change the collision threshold from 1 to 2
    % this causes the collision system to regard any two notes that are 2 semitones apart as colliding
    \override Stem.note-collision-threshold = #2    % collision of noteheads on the same stem
    \override NoteCollision.note-collision-threshold = #2 % collision of different voices on the same staffline

    \override Stem.before-line-breaking = #(stem-before-line-breaking)

    #(if unify-dots?
      #{
        \override Dots.transparent = #dots-shift-to-stem-tip
      #}
      #{ #}
      )
    

    
    
    #(if (= thick-staffline 1)
      #{
        \override StaffSymbol.thickness = #1.8
      #}
      #{ #}
      )
    
    % setting the ledge line thickness to be identical to the staff line thickness
    % default value was #'(1.0 0.1)
    \override StaffSymbol.ledger-line-thickness = #'(1.0 . 0.0)

    \clef treble

    #(if (eq? express-showpianoroll 1)
       #{
         \override Staff.InstrumentName.stencil = 
           #(ly:stencil-scale pianoroll 1 (* 1.75 express-staff-space))

          % setting 0 extent since otherwise it causes the space calculations to become wrong
          \override Staff.InstrumentName.Y-extent = #'(0 . 0)
          \override Staff.InstrumentName.extra-offset = #'(0 . -4.3)
          \set Staff.instrumentName = "dummy"
          \set Staff.shortInstrumentName = "dummy"
       #})

    \remove "Accidental_engraver"
    \remove "Key_engraver"
    \numericTimeSignature
  }

  \context {
    \PianoStaff 
    % Add the name here to center it between the staves
    
    #(if (eq? express-showpianoroll 1)
    #{
      \omit SystemStartBrace
      \set PianoStaff.instrumentName = ##f
    #}
    #{
        \set PianoStaff.instrumentName = \markup { 
          \rotate #90 { 
            \center-column { 
              "Express" 
              \line {"Stave" \fontsize #-4 #(if (= express-pianoforte 1) "" "(Original)")}
              
              }}}
    #})
  }
}

