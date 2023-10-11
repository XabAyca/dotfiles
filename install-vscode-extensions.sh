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
  Hridoy.rails-snippets
  JakeBecker.elixir-ls
  karunamurti.haml
  miguelsolorio.fluent-icons
  mishkinf.goto-next-previous-member
  misogi.ruby-rubocop
  ms-azuretools.vscode-docker
  MS-CEINTL.vscode-language-pack-fr
  phoenixframework.phoenix
  tomphilbin.gruvbox-themes
  Tyriar.sort-lines
  VisualStudioExptTeam.intellicode-api-usage-examples
  VisualStudioExptTeam.vscodeintellicode
  ryuta46.multi-command
  ms-vscode.live-server
  shopify.ruby-lsp
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done
