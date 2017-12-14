# catalogue

Please open the workspace file (Catalogue.xcworkspace) and not the project file. The assignment application uses CocoaPods for managing the 3rd party libraries, so using the workspace file rather than the project file is required.

Note that is not required to run 'pod install', since the generated 'Pods' folder is already checked-in into the GitHub repository. 
Note that normally prefer not to check the 'Pods' folder (as per CocoaPods usage guidelines here: https://guides.cocoapods.org/using/using-cocoapods.html), as to avoid potential conflicts during Git pull operations. For this assignment, I chose instead to make it easier for the evaluator to quickly build the application, without having to run 'pod install' 

SSL Pinning: I have used Alamofire's feature for validating the server trust using the 'pinned certificates' in the application bundle. As required by Alamofire, I have included the DER binary format version of the supplied certificate into the bundle for this purpose. I have obtained the DER format by issuing the following command against the 'openssl' utility:
	openssl x509 -in certificate.crt -outform der -out certificate.der
	
I have used XCode Version 9.0 (9A235) and Swift version 3.2 for the assignment.
