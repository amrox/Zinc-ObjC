platform :ios, "8.4"
inhibit_all_warnings!

abstract_target 'Zinc_iOS' do

	pod 'AMError', '~> 0.2.6'
	podspec :path => "Zinc.podspec"

	target 'Zinc' do 
	end

	target 'ZincDemo' do
		pod 'Zinc', :path => "Zinc.podspec"
	end

	target 'ZincTests' do
		pod 'OCMock', '~> 2.2.1'
		pod 'Kiwi', '~> 2.4'
	end

	target 'ZincFunctionalTests' do
		pod 'GHUnitIOS', '~> 0.5.6'
	end

end

#abstract_target 'Zinc_OSX' do
#
#	platform :osx, "10.8"
#
#	pod 'AMError', :git => 'https://github.com/amrox/AMError.git'
#	podspec :path => "Zinc.podspec"
#	
#	target 'Zinc'do
#	end
#	
#	target 'ZincTests-OSX' do
#		pod 'OCMock', '~> 2.2.1'
#		pod 'Kiwi', '~> 2.2.3'
#	end
#end


