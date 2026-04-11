#!/usr/bin/env bash
set -euo pipefail

PALETTE_URL="https://raw.githubusercontent.com/ionawr/catppuccin-palette/main/palette.json"

# fetch palette and build LESS lines
palette=$(curl -sfL "$PALETTE_URL")

build_palette_line() {
  local name="$1" scheme="$2" padding="$3"
  local line
  line=$(echo "$palette" | jq -r --arg s "$scheme" '
    .[$s].colors | to_entries
    | map(select(.key != "monochrome"))
    | map("@\(.key): \(.value.hex)")
    | join("; ")
  ')
  echo "  @${name}:${padding} { ${line}; };"
}

FORK_LATTE=$(build_palette_line "latte" "light" "    ")
FORK_FRAPPE=$(build_palette_line "frappe" "dark" "   ")
FORK_MACCHIATO=$(build_palette_line "macchiato" "dark" "")
FORK_MOCHA=$(build_palette_line "mocha" "dark" "    ")

sed -i "/^@catppuccin: {$/,/^};$/ {
  s/^  @latte:.*/$FORK_LATTE/
  s/^  @frappe:.*/$FORK_FRAPPE/
  s/^  @macchiato:.*/$FORK_MACCHIATO/
  s/^  @mocha:.*/$FORK_MOCHA/
}" lib/lib.less

# --- mocha css filter replacement ---

FORK_FILTER_MOCHA='  @mocha: { @rosewater: brightness(0) saturate(100%) invert(92%) sepia(5%) saturate(704%) hue-rotate(320deg) brightness(99%) contrast(93%); @flamingo: brightness(0) saturate(100%) invert(81%) sepia(5%) saturate(987%) hue-rotate(315deg) brightness(107%) contrast(90%); @pink: brightness(0) saturate(100%) invert(86%) sepia(11%) saturate(1177%) hue-rotate(283deg) brightness(101%) contrast(92%); @mauve: brightness(0) saturate(100%) invert(65%) sepia(58%) saturate(255%) hue-rotate(224deg) brightness(96%) contrast(102%); @red: brightness(0) saturate(100%) invert(61%) sepia(19%) saturate(997%) hue-rotate(294deg) brightness(104%) contrast(91%); @maroon: brightness(0) saturate(100%) invert(66%) sepia(16%) saturate(1301%) hue-rotate(306deg) brightness(116%) contrast(84%); @peach: brightness(0) saturate(100%) invert(68%) sepia(57%) saturate(278%) hue-rotate(338deg) brightness(98%) contrast(101%); @yellow: brightness(0) saturate(100%) invert(90%) sepia(70%) saturate(380%) hue-rotate(313deg) brightness(102%) contrast(95%); @green: brightness(0) saturate(100%) invert(88%) sepia(6%) saturate(2015%) hue-rotate(63deg) brightness(104%) contrast(78%); @teal: brightness(0) saturate(100%) invert(92%) sepia(12%) saturate(991%) hue-rotate(108deg) brightness(93%) contrast(90%); @sky: brightness(0) saturate(100%) invert(84%) sepia(21%) saturate(1302%) hue-rotate(164deg) brightness(106%) contrast(84%); @sapphire: brightness(0) saturate(100%) invert(74%) sepia(20%) saturate(876%) hue-rotate(156deg) brightness(96%) contrast(93%); @blue: brightness(0) saturate(100%) invert(68%) sepia(18%) saturate(951%) hue-rotate(180deg) brightness(98%) contrast(100%); @lavender: brightness(0) saturate(100%) invert(73%) sepia(7%) saturate(1670%) hue-rotate(195deg) brightness(102%) contrast(99%); @text: brightness(0) saturate(100%) invert(96%) sepia(10%) saturate(157%) hue-rotate(202deg) brightness(115%) contrast(91%); @subtext1: brightness(0) saturate(100%) invert(100%) sepia(0%) saturate(1732%) hue-rotate(4deg) brightness(113%) contrast(76%); @subtext0: brightness(0) saturate(100%) invert(93%) sepia(0%) saturate(0%) hue-rotate(191deg) brightness(86%) contrast(90%); @overlay2: brightness(0) saturate(100%) invert(83%) sepia(0%) saturate(0%) hue-rotate(209deg) brightness(74%) contrast(132%); @overlay1: brightness(0) saturate(100%) invert(59%) sepia(0%) saturate(6%) hue-rotate(190deg) brightness(95%) contrast(90%); @overlay0: brightness(0) saturate(100%) invert(46%) sepia(8%) saturate(0%) hue-rotate(138deg) brightness(92%) contrast(88%); @surface2: brightness(0) saturate(100%) invert(28%) sepia(19%) saturate(0%) hue-rotate(292deg) brightness(100%) contrast(86%); @surface1: brightness(0) saturate(100%) invert(21%) sepia(7%) saturate(0%) hue-rotate(174deg) brightness(100%) contrast(97%); @surface0: brightness(0) saturate(100%) invert(11%) sepia(75%) saturate(0%) hue-rotate(157deg) brightness(99%) contrast(95%); @base: brightness(0) saturate(100%) invert(0%) sepia(48%) saturate(7476%) hue-rotate(18deg) brightness(122%) contrast(83%); @mantle: brightness(0) saturate(100%) invert(0%) sepia(7%) saturate(22%) hue-rotate(328deg) brightness(76%) contrast(91%); @crust: brightness(0) saturate(100%) invert(0%) sepia(8%) saturate(7340%) hue-rotate(89deg) brightness(91%) contrast(106%); };'

sed -i "/^@catppuccin-filters: {$/,/^};$/ s/^  @mocha:.*/$FORK_FILTER_MOCHA/" lib/lib.less

# --- flavour selector: remove frappe/macchiato, rename to Light/Dark ---

for file in styles/*/catppuccin.user.less template/catppuccin.user.less; do
  [ -f "$file" ] || continue
  sed -i \
    -e 's|\["latte:Latte\*", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha"\]|["latte:Light*", "mocha:Dark"]|g' \
    -e 's|\["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha\*"\]|["latte:Light", "mocha:Dark*"]|g' \
    "$file"
done
