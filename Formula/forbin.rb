class Forbin < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/Forbin"
  url "https://files.pythonhosted.org/packages/77/86/2dcaf32b40f95dcbea9940513bd33c62b564e2f523238112f4de24bb9c0e/forbin_mcp-0.1.0.tar.gz"
  sha256 "2d92fbdab6e9dd517edab8368c7e35acf1319fe45f50f0e0594986adee2fdbcc"
  license "MIT"

  depends_on "python@3.13"

  skip_clean "libexec"

  def install
    python = Formula["python@3.13"].opt_bin/"python3.13"

    system python, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", "forbin-mcp==0.1.0"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
