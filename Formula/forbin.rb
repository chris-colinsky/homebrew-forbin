class Forbin < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/Forbin"
  url "https://files.pythonhosted.org/packages/dc/ab/4ab7d62fc91bb50d15b036aa310ea34d3e2fa8cb6d14f64c8d3b6e7ea631/forbin_mcp-0.1.2.tar.gz"
  sha256 "923c3998eace47b68a4d2893a7eabfaf7c580ad9beb9170503d69c298781db28"
  license "MIT"

  bottle do
    rebuild 2
    root_url "https://github.com/chris-colinsky/homebrew-forbin/releases/download/forbin-0.1.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4ad50557398d9abf7890610393e68d2c5c4323b19a0ff37a83c3474b74d3e1c0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7d3d6b8b50e5c10c0b2f84087d3961b0456d6304f9fd3a725b9c90e1bc114cf4"
  end

  depends_on "python@3.13"
  depends_on "rust" => :build

  skip_clean "libexec"

  def install
    python = Formula["python@3.13"].opt_bin/"python3.13"

    # Several Rust extension wheels in the dep tree (cryptography, pydantic-core,
    # rpds-py, watchfiles, ...) ship without -headerpad_max_install_names, so
    # Homebrew's post-install relocation step fails trying to rewrite their
    # @rpath dylib IDs to long absolute paths. --no-binary :all: forces every
    # wheel to be built from source so this RUSTFLAGS linker flag applies to
    # every Rust extension regardless of which transitive dep introduced it.
    ENV.append "RUSTFLAGS", "-C link-arg=-headerpad_max_install_names"

    system python, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install",
           "--no-binary", ":all:",
           "forbin-mcp==0.1.2"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
