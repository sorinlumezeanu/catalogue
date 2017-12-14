Please open the workspace file (Catalogue.xcworkspace) and not the project file. The assignment application uses CocoaPods for managing the 3rd party libraries, so using the workspace file rather than the project file is required.

Note that is not required to run 'pod install' (although you can if you wish to), since the generated code for the included 3rd parties is already in the assignment '.zip' file.

SSL Pinning: I have used Alamofire's feature for validating the server trust using the 'pinned certificates' in the application bundle. As required by Alamofire, I have included the DER binary format version of the supplied certificate into the bundle for this purpose. I have obtained the DER format by issuing the following command against the 'openssl' utility:
	openssl x509 -in certificate.crt -outform der -out certificate.der
	
I have used XCode Version 9.0 (9A235) and Swift version 3.2 for the assignment.
	
	
