class Forbin < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/Forbin"
  url "https://files.pythonhosted.org/packages/dc/ab/4ab7d62fc91bb50d15b036aa310ea34d3e2fa8cb6d14f64c8d3b6e7ea631/forbin_mcp-0.1.2.tar.gz"
  sha256 "923c3998eace47b68a4d2893a7eabfaf7c580ad9beb9170503d69c298781db28"
  license "MIT"

  depends_on "python@3.13"
  depends_on "rust" => :build

  skip_clean "libexec"

  def install
    python = Formula["python@3.13"].opt_bin/"python3.13"

    # The cryptography and pydantic-core Rust extension wheels ship without
    # -headerpad_max_install_names, so Homebrew's post-install relocation step
    # fails trying to rewrite their @rpath dylib IDs to long absolute paths.
    # Building them from source with this linker flag resolves the issue.
    ENV.append "RUSTFLAGS", "-C link-arg=-headerpad_max_install_names"

    system python, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install",
           "--no-binary", "cryptography,pydantic-core",
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
