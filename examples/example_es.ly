\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
#(define express-pianoforte 1) % uncomment for express stave original notation (white piano keys = white notes)
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = 	"Express Stave Demo"
  subtitle = #(if (and (defined? 'express-pianoforte) (= express-pianoforte 1)) "Pianoforte Notation" "Orignal Notation")
	opus = 	\markup \tiny \line {"Library Version: " #ES_VERSION }
	composer =	"Express Stave by John Keller"
	style =	"Music Style"
  footer = "Express Stave"
 }

\paper {
  system-system-spacing = % spacing between note systems
    #'((basic-distance .  15.955)
       (minimum-distance . 8)
       (padding . 1)
       (stretchability . 0))

  #(layout-set-staff-size 17.55) % general staff size
}

\layout {
  \context {
    \Score
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

\parallelMusic #'(voiceA voiceB) {
  \tempo"Andante très expressif"
  \clef treble
   c'4 \pp cis' _\markup\italic"chromatic scale" d' dis' |
   \clef bass
   c2 d _\markup\italic"major scale" |
   e'4 f' fis' g' |
   e2 f |
   gis'4 a' ais' b' |
   g2 a |
   \break

   c''4 \< cis'' d'' dis'' \! |
   b2 c' |
   e''4( f'' fis'' g'') |
   d'2 e'2 |
   gis''4 \> a'' ais'' b'' \! |
   f'2 g' |
   \break

  <c' e' g'>4 _\markup\italic"chords" \< <c'' e'' g''>4 -- <c''' e''' g'''>4  -> r4 \! |
  \stemUp <a, c dis fis> \stemNeutral <ais, cis e g> <b, d f gis> _\markup\italic"rests" r8 r16 r16 \bar "||" |

  % \snhs #'(0 -2 0 0 0 0 0 2)   % manual shifting of crammed notes. uncomment to see the effect
  <c' d' e' f' g' a' b' c''>2 \mf
  <c'' d'' e'' f'' g'' a'' b'' c'''>8 
  _\markup\italic"crammed chords"
  <cis''' dis''' f''' fis''' gis''' ais'''>8
  % r4 
  <e'' fis'' b' cis''>8
  <e'' dis'' cis'' c''>8 |
  c'16 b a g  f16 e d c  c16 b, a, g,  f,16 e, d, c, |
  \clef bass
  <d' ais>16 _\markup\italic"clef changes"
  \clef alto
  <d' ais>2.
  \clef treble
  <d' ais>8. |
  cis'16 _\markup\italic"low notes " ais16 gis fis dis cis ais, gis, fis, dis, cis, ais,, 
  gis,, fis,, 
  \revert Stem.details.beamed-lengths r8 |
  \break
  \clef treble
  
  g''4 _\markup\italic"ottava"
  \ottava #1
  g'' g'' 
  \ottava #0
  g'' |
  g,8 g, g, g,
  \ottava #-1
  g,8 g, g, g, \ottava #0 | 
  a'16 ais' c'' cis'' dis'' e'' fis'' g''
  % cis'' e''
  \tiny a'16 ais'  _\markup\italic\normalsize"tiny notes" c'' cis'' dis'' e'' fis'' g'' \normalsize 
  
  \stemNeutral
  % \huge a'32 ais' b' c'' cis'' d'' dis'' e'' f'' fis'' g'' gis'' \normalsize 
   |
  g,8 g, g, g,
  
  \clef bass
  g,8 g, g, g,  | 
  <c'' a' f'>2. c''4  \fermata |
  a16 _\markup\italic"high notes" b c' d' e' f' g' a'  
  \override Stem.details.beamed-lengths = #'(6.5) b' c'' d'' e'' 
  \revert Stem.details.beamed-lengths r4 |
  \break
  c''1 _\msg"C" _\msg"0"  cis'' _\msg"I" _\msg"1" d'' _\msg"D" _\msg"2" dis'' _\msg"J" _\msg"3"
  e'' _\msg"E" _\msg"4" f'' _\msg"F" _\msg"5" fis'' _\msg"K" _\msg"6" g'' _\msg"G" _\msg"7"
  gis''_\msg"L" _\msg"8" a'' _\msg"A" _\msg"9" ais'' _\msg"H" _\msg"10" b''_\msg"B" _\msg"11" 
  c''' _\msg"C" _\msg"0"
  \bar "|."
}



  \new PianoStaff <<
    \new Staff { \numericTimeSignature \voiceA }
    \new Staff { \clef bass \voiceB }
  >>

