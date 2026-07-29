# AISLAR Connect — Firestore Database Design v1.0

## 1. Naming Conventions

- Collections: `snake_case` (plural)
- Documents: auto-generated `push IDs` unless noted
- Fields: `camelCase`
- Timestamps: Firestore `Timestamp` type (`createdAt`, `updatedAt`)
- Soft deletes: `isDeleted: boolean` + `deletedAt: Timestamp | null`
- Status fields: lowercase strings (`"active"`, `"pending"`, `"inactive"`)

---

## 2. Collections & Schemas

### 2.1 `users`

Stores authentication and access metadata. Core identity document.

```
users/{userId}
{
  uid: string               // Firebase Auth UID
  email: string
  phone: string | null
  displayName: string
  photoURL: string | null
  role: "visitor" | "member" | "moderator" | "executive" | "administrator" | "super_admin"
  status: "pending" | "active" | "suspended" | "deactivated"
  isApproved: boolean       // admin gate
  approvedBy: string | null // admin uid
  approvedAt: Timestamp | null
  lastLoginAt: Timestamp
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `status` ASC, `createdAt` DESC
- `role` ASC, `status` ASC
- `email` (unique – enforced by Firebase Auth)

**Security rules:**
- Read: authenticated users
- Write: `super_admin` only (profile edits go through `profiles`)

---

### 2.2 `profiles`

Public-facing member profile.

```
profiles/{userId}
{
  uid: string               // matches users/{userId}
  fullName: string
  nickname: string | null
  matricNumber: string | null
  department: string
  faculty: string
  admissionYear: number
  graduationYear: number
  phone: string | null
  email: string              // read-only from auth
  currentAddress: string | null
  city: string | null
  country: string
  occupation: string | null
  employer: string | null
  business: string | null
  skills: string[]
  bio: string | null
  socialLinks: {
    whatsapp: string | null
    facebook: string | null
    twitter: string | null
    linkedin: string | null
    instagram: string | null
  }
  photoURL: string | null
  coverURL: string | null
  maritalStatus: "single" | "married" | "divorced" | "widowed" | null
  isExecutive: boolean
  isCommitteeMember: boolean
  committeeRoles: string[]
  visibility: "public" | "members_only"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `graduationYear` ASC, `department` ASC
- `country` ASC, `occupation` ASC
- `fullName` (composite for search — see search strategy)
- Array-contains indexes on `skills`

**Search strategy:** Use Algolia/Typesense for full-text search on name, department, occupation, skills. Firestore `array-contains` for basic skill/department filters.

---

### 2.3 `roles`

Flexible role-based access control (RBAC).

```
roles/{roleId}
{
  name: "moderator" | "executive" | "administrator" | "super_admin"
  permissions: string[]   // e.g. ["members:approve", "posts:delete", "events:manage"]
  description: string
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Security rules:** Only `super_admin` can CRUD.

---

### 2.4 `posts`

Community news feed posts.

```
posts/{postId}
{
  authorId: string          // reference to users/{uid}
  content: string
  mediaURLs: string[]
  mediaTypes: ("image" | "video" | "document")[]
  tags: string[]
  mentionIds: string[]
  isPinned: boolean
  isAnnouncement: boolean   // only executives/admins
  status: "published" | "hidden" | "reported"
  likeCount: number
  commentCount: number
  shareCount: number
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `authorId` ASC, `createdAt` DESC
- `isPinned` DESC, `createdAt` DESC
- `status` ASC, `createdAt` DESC
- `tags` ASC (array-contains)

---

### 2.5 `comments`

```
comments/{commentId}
{
  postId: string
  authorId: string
  parentId: string | null   // for nested replies
  content: string
  mediaURL: string | null
  likeCount: number
  isEdited: boolean
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `postId` ASC, `createdAt` ASC
- `authorId` ASC, `createdAt` DESC
- `parentId` ASC, `createdAt` ASC

---

### 2.6 `likes`

```
likes/{likeId}
{
  postId: string | null     // polymorphic — either postId or commentId
  commentId: string | null
  userId: string
  createdAt: Timestamp
}
```

**Indexes:**
- `postId` ASC, `userId` ASC (unique compound)
- `commentId` ASC, `userId` ASC (unique compound)

**Security rules:** Prevent duplicate likes via `exists()`. Delete on unlike.

---

### 2.7 `chat_rooms`

```
chat_rooms/{roomId}
{
  type: "direct" | "group" | "committee" | "executive"
  name: string | null       // null for direct chats
  photoURL: string | null
  memberIds: string[]
  adminIds: string[]
  lastMessage: {
    text: string
    senderId: string
    senderName: string
    sentAt: Timestamp
    type: "text" | "image" | "video" | "voice" | "document"
  } | null
  isArchived: boolean
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `memberIds` ASC (array-contains)
- `type` ASC, `updatedAt` DESC

---

### 2.8 `messages`

```
messages/{messageId}
{
  roomId: string
  senderId: string
  content: string
  type: "text" | "image" | "video" | "voice" | "document"
  mediaURL: string | null
  replyTo: string | null    // messageId
  mentions: string[]
  readBy: string[]
  deliveredTo: string[]
  isEdited: boolean
  isDeleted: boolean        // soft delete
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `roomId` ASC, `createdAt` ASC
- `roomId` ASC, `createdAt` DESC
- `senderId` ASC, `createdAt` DESC

---

### 2.9 `events`

```
events/{eventId}
{
  title: string
  description: string
  type: "agm" | "reunion" | "webinar" | "birthday" | "seminar" | "social"
  bannerURL: string | null
  startDate: Timestamp
  endDate: Timestamp
  location: {
    name: string
    address: string | null
    lat: number | null
    lng: number | null
    isVirtual: boolean
    meetingLink: string | null
  }
  organizerId: string
  maxAttendees: number | null
  rsvpDeadline: Timestamp | null
  ticketPrice: number | null   // in local currency
  currency: string | null
  status: "draft" | "published" | "cancelled" | "completed"
  attendeeCount: number
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `status` ASC, `startDate` ASC
- `organizerId` ASC, `startDate` DESC
- `type` ASC, `startDate` ASC

---

### 2.10 `attendees`

```
attendees/{attendeeId}
{
  eventId: string
  userId: string
  status: "interested" | "going" | "attended" | "cancelled"
  rsvpAt: Timestamp
  checkedInAt: Timestamp | null
  ticketId: string | null
  createdAt: Timestamp
}
```

**Indexes:**
- `eventId` ASC, `status` ASC
- `userId` ASC, `eventId` ASC (unique compound)

---

### 2.11 `albums`

```
albums/{albumId}
{
  title: string
  description: string | null
  coverURL: string | null
  type: "graduation" | "reunion" | "throwback" | "wedding" | "memorial" | "general"
  createdBy: string
  isFeatured: boolean
  photoCount: number
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `type` ASC, `createdAt` DESC
- `isFeatured` DESC
- `createdBy` ASC, `createdAt` DESC

---

### 2.12 `photos`

```
photos/{photoId}
{
  albumId: string
  uploadedBy: string
  url: string
  thumbnailURL: string
  caption: string | null
  tags: string[]
  mentionIds: string[]
  likeCount: number
  createdAt: Timestamp
}
```

**Indexes:**
- `albumId` ASC, `createdAt` ASC
- `uploadedBy` ASC, `createdAt` DESC

---

### 2.13 `videos`

```
videos/{videoId}
{
  albumId: string | null
  uploadedBy: string
  url: string
  thumbnailURL: string
  caption: string | null
  duration: number         // seconds
  likeCount: number
  createdAt: Timestamp
}
```

**Indexes:**
- `albumId` ASC, `createdAt` ASC
- `uploadedBy` ASC, `createdAt` DESC

---

### 2.14 `documents` (Digital Library)

```
documents/{documentId}
{
  title: string
  description: string | null
  type: "constitution" | "minutes" | "report" | "financial_statement" | "yearbook" | "newsletter" | "other"
  fileURL: string
  fileSize: number        // bytes
  fileType: string        // MIME
  uploadedBy: string
  isPublic: boolean       // accessible to non-members
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `type` ASC, `createdAt` DESC
- `isPublic` ASC, `createdAt` DESC
- `uploadedBy` ASC, `createdAt` DESC

---

### 2.15 `businesses`

```
businesses/{businessId}
{
  ownerId: string
  name: string
  description: string
  category: "law" | "medical" | "engineering" | "agriculture" | "education" | "ict" | "fashion" | "entertainment" | "real_estate" | "transport" | "food" | "other"
  logoURL: string | null
  coverURL: string | null
  contactEmail: string | null
  contactPhone: string | null
  website: string | null
  socialLinks: {
    instagram: string | null
    facebook: string | null
    twitter: string | null
    linkedin: string | null
  }
  address: string | null
  city: string | null
  country: string
  isVerified: boolean
  isFeatured: boolean
  status: "active" | "inactive"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `category` ASC, `status` ASC
- `ownerId` ASC
- `isFeatured` DESC, `createdAt` DESC
- `country` ASC, `city` ASC

---

### 2.16 `jobs`

```
jobs/{jobId}
{
  postedBy: string
  businessId: string | null
  title: string
  description: string
  type: "full_time" | "part_time" | "contract" | "internship" | "volunteer"
  category: "scholarship" | "job" | "volunteer" | "business_opportunity"
  location: string | null
  isRemote: boolean
  salary: string | null    // free text to support multiple currencies
  applicationURL: string | null
  applicationEmail: string | null
  deadline: Timestamp | null
  status: "open" | "closed"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `status` ASC, `createdAt` DESC
- `category` ASC, `status` ASC
- `postedBy` ASC, `createdAt` DESC
- `type` ASC, `status` ASC

---

### 2.17 `polls`

```
polls/{pollId}
{
  title: string
  description: string | null
  type: "election" | "survey" | "opinion"
  options: {
    id: string
    text: string
  }[]
  createdBy: string
  startsAt: Timestamp
  endsAt: Timestamp
  isAnonymous: boolean
  allowedRoles: string[]   // null means all members
  totalVotes: number
  status: "draft" | "active" | "closed"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Indexes:**
- `status` ASC, `endsAt` ASC
- `createdBy` ASC, `createdAt` DESC
- `type` ASC, `status` ASC

---

### 2.18 `votes`

```
votes/{voteId}
{
  pollId: string
  userId: string
  selectedOptionId: string
  castAt: Timestamp
}
```

**Indexes:**
- `pollId` ASC, `userId` ASC (unique compound — one vote per user per poll)
- `pollId` ASC, `selectedOptionId` ASC (for tallying)

---

### 2.19 `notifications`

```
notifications/{notificationId}
{
  recipientId: string
  type: "birthday" | "meeting" | "announcement" | "message" | "event" | "approval" | "mention" | "system"
  title: string
  body: string
  data: {                   // payload for navigation
    screen: string
    id: string | null
  }
  isRead: boolean
  readAt: Timestamp | null
  createdAt: Timestamp
}
```

**Indexes:**
- `recipientId` ASC, `isRead` ASC, `createdAt` DESC
- `recipientId` ASC, `createdAt` DESC

---

### 2.20 `donations`

```
donations/{donationId}
{
  donorId: string
  amount: number
  currency: string
  fundType: "reunion" | "welfare" | "emergency" | "scholarship" | "general"
  paymentMethod: "card" | "transfer" | "ussd" | "other"
  paymentReference: string
  receiptURL: string | null
  message: string | null
  isAnonymous: boolean
  status: "pending" | "completed" | "failed" | "refunded"
  campaignId: string | null
  createdAt: Timestamp
}
```

**Indexes:**
- `donorId` ASC, `createdAt` DESC
- `fundType` ASC, `status` ASC
- `campaignId` ASC
- `status` ASC, `createdAt` ASC

---

### 2.21 `audit_logs`

```
audit_logs/{logId}
{
  actorId: string
  action: string            // e.g. "member.approve", "post.delete", "role.change"
  targetType: string        // "user" | "post" | "event" | "role" | etc.
  targetId: string
  changes: {                // snapshot of what changed
    before: any | null
    after: any | null
  }
  ipAddress: string | null
  userAgent: string | null
  createdAt: Timestamp
}
```

**Indexes:**
- `actorId` ASC, `createdAt` DESC
- `action` ASC, `createdAt` DESC
- `targetType` ASC, `targetId` ASC
- `createdAt` DESC (for global timeline)

---

### 2.22 `settings`

Singleton-like document for platform-wide configuration.

```
settings/{settingId}
{
  key: string               // e.g. "platform", "donations", "registration"
  value: {
    platformName: "AISLAR Connect"
    tagline: "One Class. One Network. Forever Connected."
    logoURL: string
    faviconURL: string
    primaryColor: string
    isRegistrationOpen: boolean
    requireAdminApproval: boolean
    defaultRole: "member"
    timezone: "Africa/Lagos"
    currency: "NGN"
    paymentGateway: "paystack" | "flutterwave" | "stripe"
    ... (extensible)
  }
  updatedBy: string
  updatedAt: Timestamp
}
```

---

## 3. Relationships Diagram

```
users (1) ──< (1) profiles
users (1) ──< (*) roles       (via role field + roles collection)
users (1) ──< (*) posts
users (1) ──< (*) comments
users (1) ──< (*) likes
users (1) ──< (*) messages
users (1) ──< (*) notifications
users (1) ──< (*) donations
users (1) ──< (*) businesses
users (1) ──< (*) jobs
users (1) ──< (*) polls      (as creator)
users (1) ──< (*) votes

posts (1) ──< (*) comments
posts (1) ──< (*) likes

chat_rooms (1) ──< (*) messages
chat_rooms (*) ──< (*) users   (via memberIds)

events (1) ──< (*) attendees
events (1) ──< (*) posts       (announcements)

albums (1) ──< (*) photos
albums (1) ──< (*) videos

polls (1) ──< (*) votes

businesses (1) ──< (*) jobs
```

---

## 4. Composite Indexes (Firestore)

Firestore requires explicit composite indexes for queries that filter on multiple fields. Below are all needed indexes beyond single-field defaults.

| Collection | Fields (ASC unless noted) |
|---|---|
| `profiles` | `country` ASC, `occupation` ASC |
| `profiles` | `graduationYear` ASC, `department` ASC |
| `profiles` | `skills` (array-contains), `country` ASC |
| `posts` | `authorId` ASC, `createdAt` DESC |
| `posts` | `status` ASC, `createdAt` DESC |
| `posts` | `isPinned` DESC, `createdAt` DESC |
| `comments` | `postId` ASC, `createdAt` ASC |
| `comments` | `parentId` ASC, `createdAt` ASC |
| `events` | `status` ASC, `startDate` ASC |
| `events` | `organizerId` ASC, `startDate` DESC |
| `messages` | `roomId` ASC, `createdAt` ASC |
| `notifications` | `recipientId` ASC, `isRead` ASC, `createdAt` DESC |
| `donations` | `fundType` ASC, `status` ASC |
| `donations` | `donorId` ASC, `createdAt` DESC |
| `audit_logs` | `action` ASC, `createdAt` DESC |
| `jobs` | `category` ASC, `status` ASC |
| `jobs` | `status` ASC, `createdAt` DESC |
| `businesses` | `category` ASC, `status` ASC |
| `polls` | `status` ASC, `endsAt` ASC |

---

## 5. Firebase Security Rules Summary

### Core Principles
- No public writes (except registration)
- Authenticated users can read their own data
- Role-based access for admin operations
- Validate all writes with `request.resource.data`

### Rules Pattern

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }

    function isAdmin() {
      return getUserRole() in ['administrator', 'super_admin'];
    }

    function isSuperAdmin() {
      return getUserRole() == 'super_admin';
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if request.auth.uid == userId; // self-registration
      allow update: if request.auth.uid == userId || isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Profiles collection
    match /profiles/{userId} {
      allow read: if isAuthenticated();
      allow create, update: if request.auth.uid == userId || isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Posts
    match /posts/{postId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if request.resource.data.authorId == request.auth.uid || isAdmin();
      allow delete: if request.resource.data.authorId == request.auth.uid || isAdmin();
    }

    // Messages — only room members
    match /messages/{messageId} {
      allow read: if isAuthenticated() && exists(
        /databases/$(database)/documents/chat_rooms/$(resource.data.roomId)
      ) && request.auth.uid in get(
        /databases/$(database)/documents/chat_rooms/$(resource.data.roomId)
      ).data.memberIds;
      allow create: if isAuthenticated();
      allow update, delete: if request.resource.data.senderId == request.auth.uid || isAdmin();
    }

    // Admin-only collections
    match /audit_logs/{logId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }

    match /settings/{settingId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    match /roles/{roleId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }
  }
}
```

---

## 6. Real-time Subscriptions Strategy

| Feature | Listener Pattern |
|---|---|
| Chat | `messages.where('roomId', '==', roomId).orderBy('createdAt').limit(50)` |
| Feed | `posts.where('status', '==', 'published').orderBy('createdAt', 'desc').limit(20)` |
| Notifications | `notifications.where('recipientId', '==', uid).where('isRead', '==', false)` |
| Events | `events.where('status', '==', 'published').where('startDate', '>=', now)` |

Use `.limit()` + pagination with `startAfter()` for all scrollable lists. Avoid `onSnapshot` for admin dashboards — use `get()` with caching instead.

---

## 7. Data Migration Plan

1. **Phase 1 — MVP schema** (this document): Core collections only
2. **Phase 2 — v1.1**: Add `mentorship`, `digital_id_cards`, `ai_assistant`
3. **Migration tool**: Write a `scripts/migrate.ts` using Firebase Admin SDK for each schema change
4. **Backup**: Daily Firestore exports to Cloud Storage via scheduled Cloud Function

---

## Next Deliverable

After this database design is reviewed, the next step is:

1. Set up Firebase project + Firestore database
2. Apply security rules
3. Create composite indexes
4. Initialize Flutter project with Firebase dependencies
5. Generate Dart model classes from these schemas
