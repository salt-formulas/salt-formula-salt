
%w(keepalived haproxy libvirt ntp openssh).each do |f|
  describe package("salt-formula-#{f}") do
    it { should be_installed }
  end
end

%w(mysql postgresql).each do |f|
  describe package("salt-formula-#{f}") do
    it { should_not be_installed }
  end
end

