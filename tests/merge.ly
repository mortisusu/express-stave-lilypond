\version "2.24.0"
\include "english.ly"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

hshift =
#(define-music-function (x) (number?)
   #{
     \once \override NoteColumn.force-hshift = #x
   #})

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% 1 % uncomment for express stave original notation (white piano keys = white notes)
% express-pianoforte=1
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Multi Voice Merge"
	style =	"Music Style"
  footer = "Express Stave"
 }

\paper {
  indent = 0
  short-indent = 0

  % #(layout-set-staff-size 42) % general staff size
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
    \override StaffGrouper.staff-staff-spacing.minimum-distance = #12
  }

   \context {
    \Staff
  }
}

msg =
#(define-scheme-function (text) (markup?)
   #{ \markup \fontsize #-3 #text #})

cu = { \change Staff = "1" }
cl = { \change Staff = "2" }

notes = {

  r8                     
                            <af>4  
  \stemNeutral s4. s |
  s8*9 |
  af,8 \stemDown   \cu   
                            <af>
  \stemNeutral \cl <f,> s2. |
  s4. cf'2._> |

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  r8                     
                            <ff g>4  
  \stemNeutral s4. s |
  s8*9 |
  af,8 \stemDown   \cu   
                            <ff g>
  \stemNeutral \cl <f,> s2. |
  s4. cf'2._> |

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  r8                     
                            <f af>4  
  \stemNeutral s4. s |
  s8*9 |
  af,8 \stemDown   \cu   
                            <f af>
  \stemNeutral \cl <f,> s2. |
  s4. cf'2._> |

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  r8                     
                            <e bf>4  
  \stemNeutral s4. s |
  s8*9 |
  af,8 \stemDown   \cu   
                            <e bf>
  \stemNeutral \cl <f,> s2. |
  s4. cf'2._> |

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  r8                     

  \hshift #-1
  \snhs #'(0 0 1)

                            <e f af>4  
  \stemNeutral s4. s |
  s8*9 |
  af,8 \stemDown   \cu   
  \hshift #0
                            <e f af>
  \stemNeutral \cl <f,> s2. |
  s4. cf'2._> |

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

}



\parallelMusic #'(voiceA voiceB voiceC voiceD) {
  \time 9/8
  \notes
  
}



\score {
  \new PianoStaff <<
    \new Staff = "1" <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "treble"
      \new Voice { \voiceOne \voiceA }
      % \new Voice { \voiceTwo \voiceB }
    >>
    \new Staff = "2" <<
      \mergeDifferentlyDottedOn\mergeDifferentlyHeadedOn
      \clef "bass"
      \new Voice { \voiceOne \voiceC }
      % \new Voice { \voiceTwo \voiceD }
    >>
  >>
}
