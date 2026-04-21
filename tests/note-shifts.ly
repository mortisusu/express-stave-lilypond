\version "2.24.0"

% #(define express-staff-space 0.7)
% #(define express-pianoforte 0)
% #(define express-showpianoroll 1)
\include "../lib/express-stave.ly"

\header {
  title = "Note Shifts"
}

% \pointAndClickOff
\paper {
  % annotate-spacing = ##t  % uncomment to see spacing annotations on the page
  %{
  #(set-paper-size "letter")
  annotate-spacing = ##t
  ragged-bottom = ##t
  bottom-margin =12
  %}
  % system-system-spacing =
  %   #'((basic-distance .  16)
  %      (minimum-distance . 8)
  %      (padding . 0)
  %      (stretchability . 0))
       
  % #(layout-set-staff-size 18)
  % system-count = #12
  % obsolete-between-system-padding = 1  system-system-spacing.padding = #(/ obsolete-between-system-padding staff-space)  score-system-spacing.padding = #(/ obsolete-between-system-padding staff-space)
  ragged-last-bottom = ##f
  ragged-bottom = ##f
}
% Definitios to override page-breaking 
myExplicitBreak = {
  \break
  
}
myExplicitPageBreak = {
  \pageBreak
}

\include "english.ly"

% restrain the slope of the beams
oflat = {
  \once\override Beam.damping = #3
}
% Change staff
cu = { \change Staff = "upper" }
cl = { \change Staff = "lower" }
% Suspend collision resolution so notes line up
lu = {\once \override NoteColumn.ignore-collision = ##t }
% simpler sustain commands
sd =  s8\sustainOn 
su =  s8\sustainOff
sv =  s8\sustainOff\sustainOn

\parallelMusic #'(rhUpRed rhDownGreen lhUpBlue lhDownGrey)
{
  \slurUp \phrasingSlurUp 
  \clef treble
  s8\pp \cl<f a> \cu <f' a>  s4. s4. |
  \stemDown \tieDown s8*9 |
  \clef treble
  \dynamicUp \stemUp s8*9 | 
  \dynamicUp \stemDown s8*9 |

  \stemNeutral <gf, c ef>8*9-- |
  s8*9|
  s8*9|
  s8*9|

  \stemDown <gf b c d ef>8*9-- |
  s8*9|
  s8*9|
  s8*9| 

  \stemUp <gf c ef>8*9-- |
  s8*9|
  s8*9|
  s8*9| 

  \stemUp <c d e f g a b c>8*4-- 
  \stemDown s8 <c d e f g a b c>8*4--  |
  s8*9|
  s8*9|
  s8*9|

}
rhUp = \relative c' \rhUpRed 
rhDown = \relative c' \rhDownGreen 
lhUp = \relative c' \lhUpBlue
lhDown= \relative c' \lhDownGrey



\score { 
  \new PianoStaff
  <<
    \override Score.SpacingSpanner.shortest-duration-space = #1.7
    % The 'piano' accidental style has extraNaturals false by default
    %\set PianoStaff.extraNatural = ##f
    \accidentalStyle Score.piano
    \set PianoStaff.printKeyCancellation = ##f
    \override PianoStaff.DynamicLineSpanner.staff-padding = #2
    \override PianoStaff.DynamicText.self-alignment-X = #LEFT
    \new Staff = "upper" << 
      \key df \major
      \time 9/8
      \override PianoStaff.PhrasingSlur.height-limit = #5 
      \new Voice = "red" {
  %{colorize } \override NoteHead.color = #red %}
  \rhUp
      }
      \new Voice = "green" {
  %{colorize } \override NoteHead.color = #green %}
  \rhDown
      }
      \new Voice = "dynamics" {
      }
    >>
    \new Staff = "lower" << 
      \key df \major
      \time 9/8
      \new Voice = "blue" {
  %{colorize } \override NoteHead.color = #blue %}
  \lhUp
      }
      \new Voice = "grey" {
  %{colorize } \override NoteHead.color = #grey %}
  \lhDown
  \bar "|."
      }
      \new Voice = "pedal" {
  \set Staff.pedalSustainStyle = #'bracket
      }
    >>
  >>
  \layout {
    \context {
      \Score
      % \override SpacingSpanner.spacing-increment = #3.0 % size-width
      % \override StaffGrouper.staff-staff-spacing = 
      %   #'((basic-distance . 13)
      %   (minimum-distance . 5)
      %   (padding . 0)
      %   (stretchability . 0))
        
      % \override StaffGrouper.staff-staff-spacing.padding = #0
      % \override StaffGrouper.staff-staff-spacing.basic-distance = #20
      %\consists "Span_arpeggio_engraver"
    }
  }
  % \midi {
  %   %% Remove the dynamics from the midi output
  %   \context {
  %     \Voice
  %     \remove "Dynamic_performer"
  %   }
  % }
}


