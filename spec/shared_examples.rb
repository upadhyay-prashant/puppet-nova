shared_examples_for "a Puppet::Error" do |description|
  it "with message matching #{description.inspect}" do
    expect { is_expected.to have_class_count(1) }.to raise_error(Puppet::Error, description)
  end
end

shared_examples 'generic nova service' do |service|

  context 'with default parameters' do
    it 'installs package and service' do
      is_expected.to contain_package(service[:name]).with({
        :name   => service[:package_name],
        :ensure => 'present',
        :notify => "Service[#{service[:name]}]",
        :tag    => ['openstack', 'nova-package'],
      })
      is_expected.to contain_service(service[:name]).with({
        :name      => service[:service_name],
        :ensure    => 'running',
        :hasstatus => true,
        :enable    => true,
        :tag       => 'nova-service',
      })
    end
  end

  context 'with overridden parameters' do
    let :params do
      { :enabled        => false,
        :ensure_package => '2012.1-2' }
    end

    it 'installs package and service' do
      is_expected.to contain_package(service[:name]).with({
        :name   => service[:package_name],
        :ensure => '2012.1-2',
        :notify => "Service[#{service[:name]}]",
        :tag    => ['openstack', 'nova-package'],
      })
      is_expected.to contain_service(service[:name]).with({
        :name      => service[:service_name],
        :ensure    => 'stopped',
        :hasstatus => true,
        :enable    => false,
        :tag       => 'nova-service',
      })
    end
  end

  context 'while not managing service state' do
    let :params do
      { :enabled        => false,
        :manage_service => false }
    end

    it 'does not control service state' do
      is_expected.to contain_service(service[:name]).without_ensure
    end
  end
end
