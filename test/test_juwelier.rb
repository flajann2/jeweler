require 'test_helper'

class TestJuwelier < Test::Unit::TestCase

  def build_juwelier(base_dir = nil)
    base_dir ||= git_dir_path
    FileUtils.mkdir_p base_dir

    Juwelier.new(build_spec, base_dir)
  end

  def git_dir_path
    File.join(tmp_dir, 'git')
  end

  def non_git_dir_path
    File.join(tmp_dir, 'nongit')
  end

  def build_git_dir

    FileUtils.mkdir_p git_dir_path
    Dir.chdir git_dir_path do
      Git.init
    end
  end

  def build_non_git_dir
    FileUtils.mkdir_p non_git_dir_path
  end

  should "raise an error if a nil gemspec is given" do
    assert_raises Juwelier::GemspecError do
      Juwelier.new(nil)
    end
  end

  should "know if it is in a git repo" do
    build_git_dir

    assert build_juwelier(git_dir_path).in_git_repo?
  end

  should "know if it is not in a git repo" do
    build_non_git_dir

    juwelier = build_juwelier(non_git_dir_path)
    assert ! juwelier.in_git_repo?, "juwelier doesn't know that #{juwelier.base_dir} is not a git repository"
  end

  should "find the base repo" do
    juwelier = build_juwelier(File.dirname(File.expand_path(__FILE__)))
    assert_equal File.dirname(File.dirname(File.expand_path(__FILE__))), juwelier.git_base_dir
  end

  should "build and run write gemspec command when writing gemspec" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::WriteGemspec).build_for(juwelier) { command }

    juwelier.write_gemspec
  end

  should "build and run validate gemspec command when validating gemspec" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::ValidateGemspec).build_for(juwelier) { command }

    juwelier.validate_gemspec
  end

  should "build and run build gem command when building gem" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::BuildGem).build_for(juwelier) { command }

    juwelier.build_gem
  end

  should "build and run build gem command when installing gem" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::InstallGem).build_for(juwelier) { command }

    juwelier.install_gem
  end

  should "build and run bump major version command when bumping major version" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::Version::BumpMajor).build_for(juwelier) { command }

    juwelier.bump_major_version
  end

  should "build and run bump minor version command when bumping minor version" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run

    mock(Juwelier::Commands::Version::BumpMinor).build_for(juwelier) { command }

    juwelier.bump_minor_version
  end

  should "build and run write version command when writing version" do
    juwelier = build_juwelier

    command = Object.new
    mock(command).run
    mock(command).major=(1)
    mock(command).minor=(5)
    mock(command).patch=(2)
    mock(command).build=('a1')

    mock(Juwelier::Commands::Version::Write).build_for(juwelier) { command }

    juwelier.write_version(1, 5, 2, 'a1')
  end

  should "build and run release to github command when running release_gemspec" do
    juwelier = build_juwelier
    args = {}

    command = Object.new
    mock(command).run(args)

    mock(Juwelier::Commands::ReleaseGemspec).build_for(juwelier) { command }

    juwelier.release_gemspec(args)
  end

  should "build and run release to git command when running release_to_git" do
    juwelier = build_juwelier
    args = {}

    command = Object.new
    mock(command).run(args)

    mock(Juwelier::Commands::ReleaseToGit).build_for(juwelier) { command }

    juwelier.release_to_git(args)
  end

  should "respond to gemspec_helper" do
    assert_respond_to build_juwelier, :gemspec_helper
  end

  should "respond to version_helper" do
    assert_respond_to build_juwelier, :version_helper
  end

  should "respond to repo" do
    assert_respond_to build_juwelier, :repo
  end

  should "respond to commit" do
    assert_respond_to build_juwelier, :commit
  end

end
