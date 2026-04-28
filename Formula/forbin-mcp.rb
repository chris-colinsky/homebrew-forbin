class ForbinMcp < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/forbin-mcp"
  url "https://files.pythonhosted.org/packages/e1/d4/6514a57855e0714bddf0dd2bd5d3ddfe7fc565a4e353d64f7b2d4c34688a/forbin_mcp-0.1.4.tar.gz"
  sha256 "0667f75e355e8cb82a3d43bd3a4ed869b3abe9629af4786ab263c3c6d00e81c1"
  license "MIT"

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
           "forbin-mcp==0.1.4"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
