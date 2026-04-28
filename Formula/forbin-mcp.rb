class Forbin < Formula
  desc "Interactive CLI tool for testing remote MCP (Model Context Protocol) servers"
  homepage "https://github.com/chris-colinsky/Forbin"
  url "https://files.pythonhosted.org/packages/ab/fe/2916093adf533a28afc6dbb4708eddfae508f01ef84935fa7cc2216f1c09/forbin_mcp-0.1.3.tar.gz"
  sha256 "55335da812f1d0c93785f690dd8dd93a36e91fa46aeaef8350d0b72ce700de1b"
  license "MIT"

  bottle do
    rebuild 1
    root_url "https://github.com/chris-colinsky/homebrew-forbin/releases/download/forbin-0.1.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "09241bc351123f0e5cd2c65ac56b0b31283dc5568e161e8a47c3990495e1dffc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "607e664c02865e94437680ae3ee2467f6c4a855dff6975e3bb18bc2c78f34e03"
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
           "forbin-mcp==0.1.3"

    (bin/"forbin").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/forbin" "$@"
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/forbin --help")
  end
end
