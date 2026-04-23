\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% express-staff-space  = #1.66666666 % uncomment to modify the notation space
express-pianoforte = 1
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Beams"
  subtitle =" "
	style =	"Music Style"
  footer = "Express Stave"
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
    % \override StaffSymbol.stencil = ##f
  }
}




\layout {
  \context {
    \Score
    \override MetronomeMark.padding = #2
    
  }

   \context {
    \Staff
    % \override Stem.thickness = #0
    \override Dots.color = #red
    % \override Beam.beam-thickness = #1
    % \override Beam.length-fraction = #2
    % \override Dots.transparent = #dots-shift-to-stem-tip
  }
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

mono =
#(define-scheme-function (text) (markup?)
   #{ \markup \typewriter \fontsize #-2 #text #})

notes = {

    % f'16. f' s16*7 [f'16. f']| s1 |s1 |s1|

    % g''8. g'' s8*5 | s1 | s1 |s1 | % a single beam
    
    g'8. g' s16     g'16. g' s16    [g'32. g'] s16    [g'64. g'] s16    [g'64. g']
    
    | 
    s1 | s1 | 
    b8. b s16 b16. b s16  [b32. b] s16 [b64. b] s64*7|

    f'8. _"slope" g' s16 f'16. g' s16  [f'32. g'] s32*7 | 
    s1 | s1 | 
    f8. g s16 f16. g s16  [f32. g] s32*7 |
   
    \repeat tremolo 4 { f'32 _"tremolos" g' } 
    % \once \override Beam.gap-count = #3 % A higher number covers more bars
    \repeat tremolo 12 { f'32 f' } |
    s1 |  s1|
    \repeat tremolo 4 { f32 g } 
    % \once \override Beam.gap-count = #20 % A higher number covers more bars
    % \override Beam.gap = #0.9
    % \override Beam.normalized-endpoints = #(cons 0.4 1)
    \repeat tremolo 12 { f32 g } |


    \break
    \staff-dist 12

    \repeat tremolo 6 { f'32 g' } 
    \repeat tremolo 8 { f'32 g' } s8 | 
    s1 _\mono "\staff-dist 12"| s1 |
    % \override Beam.gap = #0.9
    
    \repeat tremolo 16 { f32 g } 
    | 


    \beamauto 0 0
    \change Staff="2"
    \stemUp c'32  _\mono "\beamauto 0 0" [ \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' ]

    \beamauto 0 0
    \change Staff="2"
    \stemUp c'8 [ \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' ]
    s16|
    s1 |s1 |s1 | \noBreak


    \beamauto -1 1
    \change Staff="2" \stemUp d'32 _\mono "\beamauto -1 1" [ \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp d' \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp eis' \change Staff="1" \stemDown f'
     ]
    % r32*6

    \beamauto -1 1
    \change Staff="2" \stemUp d'8 [ \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp d' \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp eis' \change Staff="1" \stemDown f'
     ]
     s16|
    s1 |s1 |s1 |

    % \break
    % s1 | s1 | s1 | 
    % \repeat tremolo 24 { f32 g } |
    % s1 | s1 | s1 | s2 |
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
