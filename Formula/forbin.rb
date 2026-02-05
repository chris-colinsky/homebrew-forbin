class Forbin < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/Forbin"
  url "https://files.pythonhosted.org/packages/ae/7f/e7daff79e6b470ff6fe7bfe65e392f4d5aaccf0a1ab4d5da446ee028566b/forbin_mcp-0.1.1.tar.gz"
  sha256 "e54e9e47c2cc711f19774d97e2dba1741c1aee919c8232c527d7bd74d0daa131"
  license "MIT"

  depends_on "python@3.13"

  skip_clean "libexec"

  def install
    python = Formula["python@3.13"].opt_bin/"python3.13"

    system python, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", "forbin-mcp==0.1.1"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
