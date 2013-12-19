LargeCoreDataExample
====================

Example code: Parse JSON data of 10,000 items into Core Data objects on iOS, with a background operation queue.

The video is now up here: https://vimeo.com/81466705

Extra-credit challenges (not covered in this tutorial):
-------------------------------------------------------

* Add an ````NSDictionary```` with the JSON ````id```` as the key, and ````NSManagedObjectID```` as your values. (You can get it via a fetch for all objects of that entity.) Use the objectIDs in your mapping methods to look for an existing object for each JSON ````id````. If it already exists, you'll want to update the properties. If it doesn't exist, create the object. Does this adequately avoid duplicate objects? How would you guarantee that?
* Add relationship mapping. (Hint: create a class method, returning a dictionary, similar to what we used for attributes.) Return a single managed object, or a set of them, depending on the relationship type. This mapping will also need to be recursive, for any nested relationships. How would you implement this, but still keep it fast?
* There's plenty of performance improvements to be squeezed out of this example. You could likely make it faster by reducing the number of ````save:```` calls to your child context, and/or increasing the number of objects that are mapped to a context and operation before calling ````save:````.
