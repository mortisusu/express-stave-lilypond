\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.3333) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% 1 % uncomment for express stave original notation (white piano keys = white notes)
express-multi-stems=2
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = "Beams"
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
   
    \repeat tremolo 4 { f'32 _"tremolos" g' } 
    \override Beam.gap = #0.9
    % \once \override Beam.gap-count = #3 % A higher number covers more bars
    \repeat tremolo 12 { f'32 g' } |
    s1 |  s1|
    \repeat tremolo 4 { f32 g } 
    \override Beam.gap = #0.9
    % \once \override Beam.gap-count = #20 % A higher number covers more bars
    \repeat tremolo 12 { f32 g } |

    \repeat tremolo 6 { f'32 g' } 
    \override Beam.gap = #0.9
    \once \override Beam.gap-count = #3 % A higher number covers more bars
    \repeat tremolo 8 { f'32 g' } r8 | 
    s1 | s1 |
    \repeat tremolo 16 { f32 g } 
    |

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
