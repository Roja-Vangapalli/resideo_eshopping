# resideo_eshopping

## Libraries Implemented:
-	Sqflite
-	Path_provider
-	http
-	flutter_platform_widgets
-	giffy_dialog
-	carousel_pro
-	video_player
-	image_picker
-	firebase_storage, firebase_auth, firebase_core, firebase_database
-	shared_preferences
-	mobx, flutter_mobx
-	provider
-	logging
-	after_layout
-	flushbar
-	validators
-	catcher
-	dependency_validator
-	geolocator
-	flare_flutter
-	cached_network_image
-	Cupertino_icons
-	Font_awesome_flutter
-	Flutter_pdfview
-	Flutter_plugin_pdf_viewer
-	Flutter_full_pdf_viewer
-	Json_annotation, json_serializable
-	Flutter_localizations
-	Build_runner
-	Mobx_codegen
-	Mockito
-	Rxdart

## List Of UI Screens Implemented:

-	ProductListPage:  product_list_page.dart displays all products fetched from API. ProductListPageStore contains all the logic related to products.
-	ProductsTile: products_tile.dart renders the product view which displays product thumbnail, product’s title and product’s short description.
-	UserProfile: user_profile.dart shows the user profile, user details with login and logout options.
-	ProductDetail: product_detail.dart displays the product details with order now option. 
-	OrderConfirmationPage: This screen shows the order details and ask user for confirmation to order the product.
-	LoginPage: This screen provides the option to login/signup into the application. LoginPageStore contains all the logic related to login details.
-	ImagePickerDialog: This class allows the user to pick a picture which is used for profile picture. User can select the picture from gallery or take picture from camera. ImagePickerDialogStore contains the logic to persist the picture details.
-	ProductController: This class contains all the logic to update product details, inventory details from/to local db and firebase storage. API implementations are also handled in this class. 

## List of Widgets:
-	Pdf_viewer: This widget is used for displaying the pdf document.
-	ProgressIndicator: This widget is for displaying the progress dialog.
-	StarRating: This view is for giving the rating for product. 
-	TextFiled: This widget is the custom text filed which is used across the application.

## List of Util classes:
-	DBHelper: This class handles all the DB operations in the application.
-	FirebaseDBHelper: This class handles all the operations related to products from firebase. This class handles the operations with firebase.
-	Logger:  Logger library is initialized and implemented in the application.
