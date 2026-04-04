\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
#(define express-pianoforte 1) % uncomment for express stave original notation (white piano keys = white notes)
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = 	"Multi Voice Scenarios"
	style =	"Music Style"
  footer = "Express Stave"
 }

\paper {
  system-system-spacing = % spacing between note systems
    #'((basic-distance .  16)
       (minimum-distance . 8)
       (padding . 1)
       (stretchability . 0))
  
  markup-system-spacing =
    #'((basic-distance . 15)
       (minimum-distance . 10)
       (padding . 5)
       (stretchability . 0))

  indent = 0
  short-indent = 0

  #(layout-set-staff-size 20) % general staff size
}

\layout {
  \context {
    \PianoStaff 
    instrumentName = ##f
  }
}

\layout {
  \context {
    \Score
    \override MetronomeMark.padding = #2
  }

   \context {
    \Staff
  }
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

notes = {
  ais'8 _\msg"8/2 =" s4. ais'2 _\msg"2/8 ="| 
  ais'2 ais'8 s4. |
  s1|
  s1|

  d''8 _\msg"8/2" s4. ais'8 _\msg"8/2" s4.|
  ais'2 cis''2 |
  s1|
  s1|

  b'8 s8 r4 d''8 e'' f''4 | % A
  ais'2 ais'2                  | % B
  gis2 cis4 s4           | % C
  cis2 ais,2            | % D

  ais'2 _\msg"2/2" <fis' gis' ais'>2  | % A
  ais'2 s2                 |
  g1                  | % C
  c1                  | % D

  <g'c''>8 e'' r4 <g'f''>8 e'' r4 | % A
  g'2 a'2 | % B
  g1                  | % C
  c1                  | % D

  ais'2 fis''2                  | % A
  ais'8 cis'' r4 d''8 e'' f''4 | % B
  gis2 cis4 s4           | % C
  cis2 ais,2            | % D

  \break
}

\parallelMusic #'(voiceA voiceB voiceC voiceD) {
  \override Score.MetronomeMark.padding = #3

  \mergeDifferentlyDottedOff
  \mergeDifferentlyHeadedOff
  \tempo "Merge disabled:"
  \notes

  % \mergeDifferentlyDottedOff\mergeDifferentlyHeadedOff
  \mergeDifferentlyDottedOn
  \mergeDifferentlyHeadedOn
  \tempo "Merge enabled (no post-processing):"
  \override NoteColumn.before-line-breaking = ##f
  \notes

}



\score {
  \new PianoStaff <<
    \new Staff <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "treble"
      \new Voice { \voiceOne \voiceA }
      \new Voice { \voiceTwo \voiceB }
    >>
    \new Staff <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "bass"
      \new Voice { \voiceOne \voiceC }
      \new Voice { \voiceTwo \voiceD }
    >>
  >>
}


% <<
%   \relative {
%     c''8 d e d c d c4
%     g'2 fis
%   } \\
%   \relative {
%     c''2 c8. b16 c4
%     e,2 r
%   } \\
%   \relative {
%     \oneVoice
%     s1
%     e'8 a b c d2
%   }
% >>

% <<
%   \relative {
%     \mergeDifferentlyHeadedOn
%     c''8 d e d c d c4
%     g'2 fis
%   } \\
%   \relative {
%     c''2 c8. b16 c4
%     e,2 r
%   } \\
%   \relative {
%     \oneVoice
%     s1
%     e'8 a b c d2
%   }
% >>

% <<
%   \relative {
%     \mergeDifferentlyHeadedOn
%     \mergeDifferentlyDottedOn
%     c''8 d e d c d c4
%     \shiftOn
%     g'2 fis
%   } \\
%   \relative {
%     c''2 c8. b16 c4
%     e,2 r
%   } \\
%   \relative {
%     \oneVoice
%     s1
%     e'8 a b c d2
%   }
% >>