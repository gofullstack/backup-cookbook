describe 'backup-cookbook' do
  it 'has installed backup gem' do
    expect(command("su -lc \"gem list -i backup -v '4.4.0'\" root").stdout).to include('true')
  end
end
