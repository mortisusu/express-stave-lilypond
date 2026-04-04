\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% 1 % uncomment for express stave original notation (white piano keys = white notes)
express-multi-stems=1
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Single Notes"
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
  % % regular/minim voices: both voices have a single ais notehead
  % ais'8 _\msg"8/2" s8 s2.| 
  % ais'2 s2 |
  % s1|s1|

  % % regular/minim voices: stems are separated
  % ais'8 _\msg"8/2" s8 s2.| 
  % fis'2 s2 |
  % s1|s1|

  % % regular/minim voices: stems are interweaved (no colision)
  % fis'8 _\msg"8/2" s8 s2.| 
  % ais'2 s2 |
  % s1|s1|

  % % cross-stem single voice
  % \override NoteHead.stem-attachment = #'(0.7 . 0)
  % <gis' ais'>2 ais'|
  % s1|
  % s1|s1|

  % single whole note (semibreve)
    
  ais'1|
  s1|
  s1|s1|

  <b' e''>2. \override Staff.DotColumn.dot-spacing = #5.5 <b' e''>8.. s32|
  s1 |
  s1 |s1 |

  \stemDown
  <b' e''>2. <b' e''>8.. s32|
  s1 |
  s1 |s1 |


  \break
}



\parallelMusic #'(voiceA voiceB voiceC voiceD) {
  \time 4/4

  \tempo"merge (no post-processing):"
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
