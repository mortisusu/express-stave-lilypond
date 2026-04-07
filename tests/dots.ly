\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.3333) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% 1 % uncomment for express stave original notation (white piano keys = white notes)
express-multi-stems=2
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Dots"
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
  }
}




\layout {
  \context {
    \Score
    \override MetronomeMark.padding = #2
    
  }

   \context {
    \Staff
    % \override StaffSymbol.thickness = #4
    % \override Dots.transparent = #dots-shift-to-stem-tip
  }
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})



notes = {
   
  ais'1|
  r1|
  r2. r4 |s1|

  <b' c''>8.. s32 <a' e''>2. |
  s1 |
  s1|s1|

  <b' c'' e''>8.. s32 <a' e''>2. ( |
  s1 |
  c4. \stemDown c4. s4 \stemNeutral |s1 |

  \stemDown
  <b' e''>2.) <b'' e'''>8.. s32 
  \stemNeutral |
  s1 |
  s1 |c1 |

  b'8. c'8 
  s8 f'8. s8 
  b'32. c'16 s32 s64
  s128 \stemUp g'''32.. b''32 \stemNeutral
  |
  s1 |
  s1 | 
  b8. c8 
  s8 fis8. s8 
  g32. a,16 s32 s64
  s128 fis32.. g32  
   |

  \stemDown
  b'8. c'8 
  s8 b'8. s8
  b'16. c'16
  s64 b'32. c'32 
  \stemNeutral |
  s1 |
  s1 | d1|


  s1 | s1 |
  \stemUp a,8 [ \change Staff="1" \stemDown f''8. ] s8 s16 \change Staff="2" 
  \stemUp a,8. [ \change Staff="1" \stemDown f''8 ] s8 s16 \change Staff="2" 
  |
  s1 |


  b''32. c'32 
  s64 b'8. b'8 
  s8 b'16. b'16
  s8 b'8. 
  |
  s1 |
  s1 | 

  b32. c32 
  s64 b8. b8 
  s8 b16. b16
  s8 b8. 
  |
  

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
