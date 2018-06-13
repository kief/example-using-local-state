
class KeyMaker

  def self.make_key(keyname)
    Dir.mktmpdir {|dir|
      `ssh-keygen -N '' -f "#{dir}/#{keyname}" -b 4096`
      private_key = IO.read("#{dir}/#{keyname}")
      public_key = IO.read("#{dir}/#{keyname}.pub")
      {
        :private => private_key,
        :public => public_key
      }
    }
  end

end
