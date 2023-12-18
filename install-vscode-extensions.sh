pkglist=(
  alexkrechik.cucumberautocomplete
  dbaeumer.vscode-eslint
  dsznajder.es7-react-js-snippets
  eamodio.gitlens
  ecmel.vscode-html-css
  esbenp.prettier-vscode
  formulahendry.auto-rename-tag
  Gruntfuggly.activitusbar
  Hridoy.rails-snippets
  JakeBecker.elixir-ls
  karunamurti.haml
  miguelsolorio.fluent-icons
  misogi.ruby-rubocop
  ms-azuretools.vscode-docker
  phoenixframework.phoenix
  tomphilbin.gruvbox-themes
  Tyriar.sort-lines
  VisualStudioExptTeam.intellicode-api-usage-examples
  VisualStudioExptTeam.vscodeintellicode
  shopify.ruby-lsp
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done
