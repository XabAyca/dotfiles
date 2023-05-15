pkglist=(
  alexkrechik.cucumberautocomplete
  bierner.markdown-emoji
  bierner.markdown-checkbox
  dbaeumer.vscode-eslint
  dsznajder.es7-react-js-snippets
  eamodio.gitlens
  ecmel.vscode-html-css
  esbenp.prettier-vscode
  formulahendry.auto-rename-tag
  Gruntfuggly.activitusbar
  helgardrichard.helium-icon-theme
  Hridoy.rails-snippets
  JakeBecker.elixir-ls
  karunamurti.haml
  miguelsolorio.fluent-icons
  mishkinf.goto-next-previous-member
  misogi.ruby-rubocop
  ms-azuretools.vscode-docker
  MS-CEINTL.vscode-language-pack-fr
  phoenixframework.phoenix
  rebornix.ruby
  tomphilbin.gruvbox-themes
  Tyriar.sort-lines
  VisualStudioExptTeam.intellicode-api-usage-examples
  VisualStudioExptTeam.vscodeintellicode
  wingrunr21.vscode-ruby
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done
