\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.666) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% 1 % uncomment for express stave original notation (white piano keys = white notes)
express-multi-stems=2

beamauto = #(define-music-function (x) (scheme?) #{ #})
beamautos = #(define-music-function (x) (scheme?) #{ #})
staffdist = #(define-music-function (x) (scheme?) #{ #})
\include "../lib/express-stave.ly" % comment-out to show classical notation


#(define (beam-positions-callback grob default)
  (debug D-ALL "beam-positions-callback ~a ~a" grob default)
  default
)

\header {
	title = "Single Operation Use Cases"
  subtitle = "use for debugging"
  composer =  " "
 }

\paper {
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
    % \override Beam.positions = #(grob-transformer 'positions beam-positions-callback)
    % \override Beam.neutral-direction = #1
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
    
  % ais'1|
  % s1|
  % s1|s1|

  % <b' e''>8.. s32 <b' e''>2. ( |
  % s1 |
  % s1 |s1 |

  % \stemDown
  % <b' e''>2.) <b' e''>8.. s32 
  % \stemNeutral |
  % s1 |
  % s1 |s1 |

  % b'8. c'8 
  % s8 d''8. s8 
  % b'32. c'16 s32 s64
  % s64 b'32. c'32  |
  % s1 |
  % s1 |s1 |

  % \stemDown
  % b'8. c'8 
  % s8 b'8. s8
  % b'16. c'16
  % s64 b'32. c'32 
  % \stemNeutral |
  % s1 |
  % s1 | s1|

  \staffdist #11

  % a complex beam with alternating stem directions - testing beamauto
  s1 | 
  s16*4
  \change Staff="2" \stemUp \beamauto #'(0 . 0) <f ais>8 [ \change Staff="1" \stemDown <b dis' fis'>  
  \change Staff="2" \stemUp <f gis>  \change Staff="1" \stemDown <b dis' eis'> 
  \change Staff="2"  \stemUp <d fis> \change Staff="1" \stemDown <b dis' ais'> ]
  | s1 | s1 | 

  % s1 | s1 | s1 | s1 | 
  % s1 | s1 | s1 | s1 |
  % s1 | s1 | s1 | s1 |


  % s1 | s1 |
  % \stemUp a,8 [ \change Staff="1" \stemDown f''8. ] s8 s16 \change Staff="2" 
  % \stemUp a,8. [ \change Staff="1" \stemDown f''8 ] s8 s16 \change Staff="2" 
  % |
  % s1 |
  

  \break
}



\parallelMusic #'(voiceA voiceB voiceC voiceD) {
  \time 4/4

  \notes
  
}



\score {
  \new PianoStaff <<
    \new Staff = "1" <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "treble"
      \new Voice { \voiceOne \voiceA }
      \new Voice { \voiceTwo \voiceB }
    >>
    \new Staff = "2" <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "bass"
      \new Voice { \voiceOne \voiceC }
      \new Voice { \voiceTwo \voiceD }
    >>
  >>
}
