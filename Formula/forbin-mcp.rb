class ForbinMcp < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/forbin-mcp"
  url "https://files.pythonhosted.org/packages/c0/f9/4d9f2189a472413668b2397b272b96e40673e7891bd2cf37f32bd2376443/forbin_mcp-0.1.5.tar.gz"
  sha256 "9c0df1d45f97b7494602f24f1e4c06924028a00d5a5c1fd45cb30215a8ee0af8"
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
           "forbin-mcp==0.1.5"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
