# Think

## Screenshots

![Screenshot 1](screenshots/Screenshot%202026-10-13%20230618.png)
![Screenshot 2](screenshots/Screenshot%202026-10-13%20232310.png)
![Screenshot 3](screenshots/Screenshot%202026-10-13%20233852.png)
![Screenshot 4](screenshots/Screenshot%202026-10-13%20234859.png)
![Screenshot 5](screenshots/Screenshot%202026-10-14%20000449.png)
![Screenshot 6](screenshots/Screenshot%202026-10-14%20001500.png)

## 1. Why does deleting by index fail when a filter is active?

When a filter is active, the displayed list can contain different items and positions from the original `items` list. Therefore, the index of a displayed row may refer to a different item in the original list. I fixed this by passing the actual `Item` object to the delete function and removing that object instead of using the displayed index.

## 2. Why did I remove `final` from `name`? Why is `final` still useful?

I removed `final` from `name` because the details screen must be able to change an item's name after it has been created. A `final` variable can only be assigned once. I can still use `final` for values that should not be reassigned, such as the `title` of `HomeScreen` or a controller reference. This helps prevent accidental reassignment.

## 3. Why was a hot restart needed after adding `quantity`?

A hot restart recreates the app's state and initializes the items using the updated model. The existing in-memory items were created before the new field existed. A normal save or hot reload does not necessarily recreate that existing state, so a hot restart ensures the items are initialized with the new quantity field.

## 4. Why was `setState` needed after returning from the details screen?

The details screen changed the item object, but the home screen was not automatically told to rebuild. Calling `setState` in the `then` callback after `Navigator.push` tells Flutter that the home screen's displayed UI needs to be rebuilt. This shows that changing data and triggering a widget rebuild are separate things in Flutter.