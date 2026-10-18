const loadButton = document.getElementById("load-users");
const filterInput = document.getElementById("filter-input");
const statusMessage = document.getElementById("status");
const usersList = document.getElementById("users-list");

let users = [];

function renderUsers(list) {
  usersList.replaceChildren();

  for (const user of list) {
    const listItem = document.createElement("li");
    const name = document.createElement("h2");
    const email = document.createElement("p");
    const city = document.createElement("p");
    const company = document.createElement("p");

    name.textContent = user.name;
    email.textContent = `Email: ${user.email}`;
    city.textContent = `City: ${user.address.city}`;
    company.textContent = `Company: ${user.company.name}`;

    listItem.append(name, email, city, company);
    usersList.append(listItem);
  }
}

async function loadUsers() {
  loadButton.disabled = true;
  statusMessage.textContent = "Loading users...";

  try {
    const response = await fetch("https://jsonplaceholder.typicode.com/users");

    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`);
    }

    users = await response.json();
    renderUsers(users);
    statusMessage.textContent = `Successfully loaded ${users.length} user${users.length === 1 ? "" : "s"}.`;
  } catch (error) {
    console.error("Unable to load users:", error);
    statusMessage.textContent = "Error loading users. Please try again.";
  } finally {
    loadButton.disabled = false;
  }
}

loadButton.addEventListener("click", loadUsers);

filterInput.addEventListener("input", () => {
  const searchText = filterInput.value.trim().toLowerCase();
  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(searchText),
  );

  renderUsers(filteredUsers);

  if (filteredUsers.length === 0) {
    statusMessage.textContent = "No users match your filter.";
  } else {
    statusMessage.textContent = `Showing ${filteredUsers.length} of ${users.length} users.`;
  }
});
