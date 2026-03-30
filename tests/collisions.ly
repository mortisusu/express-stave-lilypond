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

  #(layout-set-staff-size 17.55) % general staff size
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
    % staff-staff-spacing: uncomment to change
    % \override StaffGrouper.staff-staff-spacing = 
    %   #'((basic-distance . 20)
    %   (minimum-distance . 8)
    %   (padding . 1)
    %   (stretchability . 0))

    % \override SpacingSpanner.spacing-increment = #10.0 % uncomment to change horizontal spacing between notes
  }

   \context {
    \Staff
  }
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

collisionChords = {
  \stemNeutral
   <a, b,>4  _\msg"1 tone (shift required)" <c d>   <cis dis> <d e>   <dis f>   <e fis> <f g>   <fis gis>
   <a, c>    _\msg"1.5 tones (no shift)"    <c dis> <cis e>   <d f>   <dis fis> <e g>   <f gis> <fis a>
   <a, cis>  _\msg"2 tones (no shift)"      <c e>   <cis f>   <d fis> <dis g>   <e gis> <f b> <fis ais>
  \stemUp   <c d e f g a b c'>4 _\msg"various examples"
  \stemUp <c d e f g a b c'>2
  \stemDown
  <cis dis f fis gis ais>4
  <c e f>2
  \stemUp
  <c e f>2
   |
   \break
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

\parallelMusic #'(voiceA) {
  \clef bass
  \time 8/4

  \override Staff.Stem.note-collision-threshold = #1
  \override NoteColumn.before-line-breaking = ##f
  \tempo"Default collision handling (incorrect collision detection)"
  \collisionChords
  \override Staff.Stem.note-collision-threshold = #2
  \tempo"collision-threshold = 2 (correct)"
  \collisionChords
  
}



  \new PianoStaff <<
    \new Staff { \numericTimeSignature \voiceA }
  >>
