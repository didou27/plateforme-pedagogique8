# Pedagogical Management Platform for the Preparatory Cycle

A browser-based, offline-ready platform created for the Higher School of Economics Oran.

## Open in VS Code

1. Open the `app` folder in VS Code.
2. Open `index.html` directly in a browser, or use the VS Code **Live Server** extension.
3. No package installation or build step is required.

## Included features

- Semester 1 and Semester 3 master timetable imported directly from `EMPLOI COMPLET(2).xlsx`, preserving all 258 non-empty timetable cells (courses, TD and TP) and their day/time/teacher/room information.
- First/second/all-level and all-semester filters, plus section and group filters.
- Fast prefix research by module, teacher, or room using searchable suggestions.
- Complete teacher directory imported from the supplied teacher-list image.
- Four icon-based timetable views: Days, Sections/Groups, Rooms, and Available/Vacant Rooms.
- Excel-style XLS and landscape PDF export for every timetable view.
- Module ZIP export containing a strictly individual Day View timetable in PDF and Excel for every matching module, with a stable unique module color.
- Sections/Groups hierarchy with merged section and lecture cells, grouped day headers, and exact time-slot columns.
- Master-matrix Excel export matching the supplied workbook structure: 32 columns, merged day headers, section/group rows, five slots per day, 400/409-point row heights, and vertically merged lecture cells.
- Conflict-safe session editor with live vacant-room selection and clickable free day/time slots for the selected section or group.
- Lecture moves are blocked whenever the section or any constituent group already has a class; TD/TP moves are blocked by a section lecture or an existing class for that group.
- Room restrictions for lectures and Computer Science practical rooms.
- Professor teaching load calculation, highest-to-lowest ranking, and red alert below 9 hours.
- Teaching-hours filters for department, semester, module type, and professor.
- Student representative registry for class, group, and level representatives.
- Student absence registry with level, semester, calendar date, and absence reason.
- Editable teacher directory initialized from the overall timetable.
- Organized PDF and Excel exports for student representatives, student absences, and the teacher directory.
- Pedagogical coordination and scientific committee meeting archives with committee president, academic level, and semester.
- Second-cycle competition archive with minutes, results, 80% and 20% lists.
- Browser-local persistence using localStorage and IndexedDB.
- CSV export of teaching hours.

## Important data note

Timetable edits and uploaded documents are stored only in the current browser profile. For multi-user deployment, connect the interface to a secured backend and database.

## Source data

The imported schedule was extracted from `EMPLOI COMPLET(2).xlsx`. The original files are included in `source_data` for reference.

## Automatic file persistence

For edits and uploaded documents to be written directly to files, start the platform with `start-platform.bat` instead of opening `index.html` directly.

1. Install Node.js if it is not already installed.
2. Double-click `start-platform.bat`.
3. Open `http://localhost:3000` if the browser does not open automatically.
4. Keep the terminal window open while using the platform.

The terminal also prints a **Network access** URL. Other computers and browsers
on the same local network can open that address while the server is running and
the host firewall permits TCP port 3000.

The platform automatically writes:

- Timetable and record changes to `storage/platform-data.json`.
- Uploaded documents to `storage/uploads/`.

When the server is restarted, saved data is loaded automatically. Back up the entire `storage` folder to preserve or move all data.

Opening `app/index.html` directly or publishing only the `app` folder to GitHub Pages uses browser-local storage because static websites cannot modify server files.

## Portable links and client-side routing

- Browser assets and API calls are resolved relative to the deployed
  application instead of using a hard-coded `localhost` host.
- Each main module has a direct route, such as `/hours`, `/coordination`, and
  `/scientific`.
- Navigation uses refresh-safe links such as
  `app/index.html?view=timetable`, which also work with VS Code Live Server
  and other static servers that do not provide routing fallback.
- The server falls back to `app/index.html` for client-side routes, so opening
  or refreshing a deep link does not return a 404.
- The Teaching Hours page can create a tokenized share link. Its route and
  token remain in the URL while navigating browser history.
- A same-origin `/login?returnTo=...` callback safely restores the encoded
  application route, including its share token, while rejecting external
  redirect targets.
- Unknown `/api/...` paths still return a JSON 404 rather than the application.

## Timetable update — 17 September 2026
The master timetable has been replaced with the supplied `source_data/emploi tt.xlsx` workbook. It contains 258 sessions for the First Year Preparatory Cycle, Semester 1, Sections 01–05 / Groups 01–30. The browser/server data version was bumped so the new master timetable replaces older cached timetable data on first launch.
