class Juwelier
  module Commands
    autoload :BuildGem,          'juwelier/commands/build_gem'
    autoload :InstallGem,        'juwelier/commands/install_gem'
    autoload :CheckDependencies, 'juwelier/commands/check_dependencies'
    autoload :ReleaseToGit,      'juwelier/commands/release_to_git'
    autoload :ReleaseGemspec,    'juwelier/commands/release_gemspec'
    autoload :ReleaseToRubygems, 'juwelier/commands/release_to_rubygems'
    autoload :ValidateGemspec,   'juwelier/commands/validate_gemspec'
    autoload :WriteGemspec,      'juwelier/commands/write_gemspec'

    module Version
      autoload :Base,      'juwelier/commands/version/base'
      autoload :BumpMajor, 'juwelier/commands/version/bump_major'
      autoload :BumpMinor, 'juwelier/commands/version/bump_minor'
      autoload :BumpPatch, 'juwelier/commands/version/bump_patch'
      autoload :Write,     'juwelier/commands/version/write'
    end
  end
end
