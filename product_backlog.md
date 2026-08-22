# Product Backlog

This product backlog contains all user stories for the Habit Tracker application, grouped by feature and ordered by priority. High-priority stories appear first, followed by medium- and low-priority stories.

## Priority Order

- **High** — Core functionality required for users to access and use the application.
- **Medium** — Important functionality that improves the user experience and application capabilities.
- **Low** — Additional functionality that provides personalization or secondary improvements.

---

# Login / Registration

## 1. Account registration

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: authentication`

**Description:**  
Allow users to register by providing their name, username, age, and country so they can create an account and access the habit tracking features.

---

## 2. Account login

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: authentication`

**Description:**  
Allow users to log in using their username and password so they can access their account and track their habits.

**Note:** Due to the current security constraints, registered credentials are not persisted in the browser cache after logout. The application currently allows login using the default username and password.

---

## 3. Error feedback on login

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: authentication`

**Description:**  
Display an appropriate error message when a user enters incorrect login credentials so they understand that the login attempt was unsuccessful.

---

# Home Page

## 4. Display weekly progress

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: home`

**Description:**  
Display the user's daily progress for each habit on the homepage so they can easily monitor their progress throughout the week.

---

## 5. View completed habits

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: home`

**Description:**  
Provide a section on the homepage showing completed habits so users can track what they have already achieved.

---

## 6. View welcome message

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: home`

**Description:**  
Display a personalized welcome message containing the user's name so they feel recognized and can confirm they are logged into the correct account.

---

# Menu / Navigation

## 7. Access menu options

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: navigation`

**Description:**  
Provide a navigation menu with options for managing habits, viewing reports, editing the profile, and signing out so users can easily access different sections of the application.

---

## 8. Navigate to habits page

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: navigation`

**Description:**  
Allow users to access the habits page from the navigation menu so they can configure and manage their habits.

---

## 9. Sign out from menu

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: navigation`, `security`

**Description:**  
Allow users to securely sign out of their account from the navigation menu and return to the login page.

---

## 10. Navigate to profile

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: navigation`

**Description:**  
Allow users to access their profile from the navigation menu so they can view and edit their personal information.

---

# Profile

## 11. Save updated information

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: profile`

**Description:**  
Save valid changes made to the user's profile so updated personal information is stored and reflected throughout the application.

---

## 12. Edit personal information

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: profile`

**Description:**  
Allow users to update their name, username, age, and country so they can keep their personal information up to date.

---

## 13. View personal information

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: profile`

**Description:**  
Display the user's saved name, username, age, and country on the profile page so they can review the information provided during registration.

---

## 14. Update name in header

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: profile`

**Description:**  
Update the name displayed in the application's header after the user changes their name in the profile so the change is immediately visible.

---

# Habits

## 15. Add a new habit

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: habits`

**Description:**  
Allow users to create new habits from the habit configuration page so they can manage and track their desired habits.

---

## 16. Delete a habit

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: habits`

**Description:**  
Allow users to delete existing habits so they can keep their habit list up to date.

---

## 17. Personalize a habit with color

**Priority:** Low  
**Labels:** `enhancement`, `priority: low`, `feature: habits`

**Description:**  
Allow users to assign a specific color to each habit so they can personalize their habits and distinguish them visually.

---

# Reports

## 18. View weekly reports

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: reports`

**Description:**  
Provide users with a report of their weekly habit progress so they can understand how well they are maintaining their habits.

---

## 19. Visualize completed habits

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: reports`

**Description:**  
Display a chart showing completed habits for each day of the week so users can quickly identify trends in their progress.

---

## 20. View all habits

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: reports`

**Description:**  
Display both completed and incomplete habits in the report so users have a comprehensive view of their habit tracking performance.

---

# Notifications

## 21. Enable/disable notifications

**Priority:** High  
**Labels:** `enhancement`, `priority: high`, `feature: notifications`

**Description:**  
Allow users to enable or disable application notifications so they can choose whether to receive reminders for their habits.

---

## 22. Add habits for notifications

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: notifications`

**Description:**  
Allow users to select specific habits for notifications so they only receive reminders for the habits they are actively working on.

---

## 23. Set notification times

**Priority:** Medium  
**Labels:** `enhancement`, `priority: medium`, `feature: notifications`

**Description:**  
Allow users to configure notifications for morning, afternoon, and evening so they receive timely reminders throughout the day.

---

# Backlog Summary

| Priority | Stories |
|---|---:|
| High | 10 |
| Medium | 11 |
| Low | 1 |
| **Total** | **23** |
