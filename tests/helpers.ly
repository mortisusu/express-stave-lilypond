\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% express-staff-space  = #1.66666666 % uncomment to modify the notation space
express-pianoforte = 1
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Helper Functions"
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

%%%%%%%%%%%%%%%%%%%%%%%%%

    s8
    <e' f'>4  
    \stemNeutral s8 ^\mono "\hshift #-1"  

    s8 
    \hshift #-1
    <e' f'>4 
    \stemNeutral s8 
    | s1 |

    s8 \stemDown   \change Staff = "1"   
    % \hshift #0
    <e' f'>
    \stemNeutral \change Staff = "2" s8 
    s8 _\mono "\hshift #0"

    s8  \stemDown \change Staff = "1" 
    \hshift #0
    <e' f'>
    \stemNeutral \change Staff = "2" s8 
    
    s8 |
    s1 |
                
%%%%%%%%%%%%%%%%%%%%%%%%%

    <c' cis' e'>4
    s16 ^\mono "\snhs #'(0 0 1)"
    \snhs #'(0 0 1)
    <c' cis' e'>4
    s16*7
    | s1| s1| s1|

%%%%%%%%%%%%%%%%%%%%%%%%%
    s1| s1|
    <gis' d'>2
    <\shiftl gis' \shiftr d'>2 ^\mono "\shiftl" _\mono "\shiftr"
    |s1|

%%%%%%%%%%%%%%%%%%%%%%%%%

    s8
    \stemDown a'16 [ g' e' g \change Staff = "2"
    \stemUp f d ] \change Staff = "1" 
    
    \beampos #'(-10 . -14)
    \stemDown a'16 [ g' e' g \change Staff = "2"
    \stemUp f d ] \change Staff = "1" 
     s8
    |
    s1 | s1 | s16*8  s16*8 _\mono "\beampos #'(-10 . -14)"|



    \break
    \staffdist 12
 
    s1 | s1 | s1 | s1 _\mono "\staffdist 12" | 
    

    s4 s16 s8
    \change Staff="2"
    \stemUp c'32 [ \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' ]
    s16
    \beamauto #'(0 . 0)
    \change Staff="2"
    \stemUp c'32 _\mono "\beamauto #'(0 . 0)" [ \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' \change Staff="2"
    \stemUp c' \change Staff="1" \stemDown f' ]

    s8 |
    s1 | s1 | s1 | \noBreak

    s4 s16
    \change Staff="2" \stemUp d'32 [ \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp d' \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp eis' \change Staff="1" \stemDown f'
     ]

    s16
    \beamauto #'(-1 . 1)
    \change Staff="2" \stemUp d'32 _\mono "\beamauto #'(-1 . 1)" [ \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp d' \change Staff="1" \stemDown e'
    \change Staff="2" \stemUp eis' \change Staff="1" \stemDown f'
     ]
    s4 |

    s1 |s1 |s1 |

    \break

    \staffdist 20
    s1 | s1 | s1 | s1 _\mono "\staffdist 20" | 

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
