\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
#(define express-pianoforte 1) % uncomment for express stave original notation (white piano keys = white notes)
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = 	"Note Collisions"
	style =	"Music Style"
  footer = "Express Stave"
  tagline = "Notation: Express Stave by John Keller"
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

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

\parallelMusic #'(voiceA) {
  \clef bass
  \time 4/4
  \override NoteCollision.force-hshift = #50

  \tempo"A single chord (useful for debugging)"
  \stemUp
  <c e g>4  
  |
  
}



  \new PianoStaff <<
    \new Staff { \numericTimeSignature \voiceA }
  >>
