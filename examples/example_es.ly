\version "2.24.0"

% dummy definitions in case we want to comment-out express-stave
snhs = #(define-music-function (offsets) (list?))

% #(define express-staff-space 1.5) % uncomment to modify the notation space
% #(define express-showpianoroll 1) % uncomment to show a small pianoroll to the left of the staff lines
% #(define express-pianoforte 0) % uncomment for express stave original notation (white piano keys = white notes)
\include "../lib/express-stave.ly" % comment-out to show classical notation

\header {
	title = 	"Express Stave Demo"
  subtitle = #(if (and (defined? 'express-pianoforte) (= express-pianoforte 1)) "Pianoforte Notation" "Orignal Notation")
	opus = 	"Op. 111, No. 20"
	composer =	"Composer Name (1810-1849)"
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

  #(layout-set-staff-size 18) % general staff size
}

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

  <c' e' g'>4 _\markup\italic"C major chords" \< <c'' e'' g''>4 -- <c''' e''' g'''>4  -> r4 \! |
  \stemUp <a, c dis fis> \stemNeutral <ais, cis e g> <b, d f gis> _\markup\italic"rests" r8 r16 r16 \bar "||" |

  % \snhs #'(0 -2 0 0 0 0 0 2)   % manual shifting of crammed notes. uncomment to see the effect
  <c' d' e' f' g' a' b' c''>4 \mf
  <c'' d'' e'' f'' g'' a'' b'' c'''>4 
  _\markup\italic"crammed chords"
  <cis''' dis''' f''' fis''' gis''' ais'''>4
  % r4 
  <e'' fis'' b' cis''>8
  <e'' dis'' cis'' c''>8 |
  c'16 b a g  f16 e d c  c16 b, a, g,  f,16 e, d, c, |
  r4
  \clef bass
  d'4 _\markup\italic"clef changes"
  \clef alto
  d'4
  \clef treble
  d'4 |
  cis'16 _\markup\italic"low notes " ais16 gis fis dis cis ais, gis, fis, dis, cis, ais,, 
  \override Stem.details.beamed-lengths = #'(4.5)gis,, fis,, 
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
  ais'4 cis''
  cis'' e''
  % \tiny a'32 ais' b' c'' cis'' d'' dis'' e'' f'' fis'' g'' gis'' _\markup\italic\normalsize"tiny notes" \normalsize 
  
  \stemNeutral
  % \huge a'32 ais' b' c'' cis'' d'' dis'' e'' f'' fis'' g'' gis'' \normalsize 
   |
  g,8 g, g, g,
  
  \clef bass
  g,8 g, g, g,  | 
  c''2 c''4  \fermata r4 |
  a16 _\markup\italic"high notes" b c' d' e' f' g' a'  
  \override Stem.details.beamed-lengths = #'(6.5) b' c'' d'' e'' 
  \revert Stem.details.beamed-lengths r4 |
  \break
  c''1 cis'' d'' dis'' e'' f'' fis'' g'' gis'' a'' ais'' b'' c''' 
  
  \bar "|."
}

\layout {
  \context {
    \Score
  }
}


  \new PianoStaff <<
    \new Staff { \numericTimeSignature \voiceA }
    \new Staff { \clef bass \voiceB }
  >>

