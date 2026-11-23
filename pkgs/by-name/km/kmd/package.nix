{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "kmd";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "DipaolaFederico";
    repo = "kmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yFtmobW/d7se6sgtqtFBFNjBr424E6S2LkDIMQuKHuQ=";
  };

  vendorHash = null;

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/DipaolaFederico/kmd/internal/cli.Version=v${finalAttrs.version}"
  ];

  # tests that bound the time spent on hostile inputs: allow slow builders
  preCheck = ''
    export KMD_TEST_TIME_SCALE=50
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage docs/kmd.1
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kmd \
      --bash <($out/bin/kmd --completion bash) \
      --zsh <($out/bin/kmd --completion zsh) \
      --fish <($out/bin/kmd --completion fish)
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast Markdown previewer for the terminal";
    homepage = "https://github.com/DipaolaFederico/kmd";
    changelog = "https://github.com/DipaolaFederico/kmd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dipaolafederico ];
    mainProgram = "kmd";
  };
})
