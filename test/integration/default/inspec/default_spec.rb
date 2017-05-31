
describe gem('backup') do
  it { should be_installed }
end

describe command("sudo gem list -i backup -v '4.4.0'") do
  its(:stdout) { should match /true/ }
end
