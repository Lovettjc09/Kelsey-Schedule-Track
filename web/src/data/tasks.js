// Returns the task definitions for a given JS Date (weekday 0=Sun...6=Sat)
export function generateTasksForDate(date) {
  const day = date.getDay() // 0=Sun, 1=Mon ... 5=Fri, 6=Sat
  if (day === 0 || day === 6) return []

  const tasks = [...dailyTasks(date)]
  if (day === 1) tasks.push(...mondayTasks(date))
  if (day === 2) tasks.push(...tuesdayTasks(date))
  if (day === 3) tasks.push(...wednesdayTasks(date))
  if (day === 4) tasks.push(...thursdayTasks(date))
  if (day === 5) tasks.push(...fridayTasks(date))
  return tasks
}

function make(title, timeSlot, minutes, freq, date, extra = {}) {
  return {
    id: `${toKey(date)}-${title.slice(0, 20).replace(/\s+/g, '-')}`,
    title,
    timeSlot,
    minutes,
    frequency: freq,
    isCompleted: false,
    assignedDate: toKey(date),
    isDeferred: false,
    originalDate: null,
    ...extra,
  }
}

function toKey(date) {
  return date.toISOString().slice(0, 10)
}

function dailyTasks(d) {
  return [
    make('Mindbody EOD class check (late cancel / no-show cleanup)', '12:30–1:00', 30, 'Daily', d),
    make('Social media engagement (respond to comments & DMs)', '12:00–12:15', 15, 'Daily', d),
  ]
}

function mondayTasks(d) {
  return [
    make('Weekly call with Josh', '9:00–9:30', 30, 'Weekly', d),
    make('Review class schedule; assign coach workouts', '9:30–10:00', 30, 'Weekly', d),
    make('Google Calendar: sub coordination & TBAs', '10:00–10:30', 30, 'Weekly', d),
    make('Social media post + reel publish', '10:30–11:00', 30, 'Weekly', d),
    make('Challenge participant check-in & motivation', '12:00–12:30', 30, 'Weekly', d),
    make('Fundraiser / challenge coordination', '12:30–1:00', 30, 'Weekly', d),
  ]
}

function tuesdayTasks(d) {
  return [
    make('Mindbody Admin: Trial follow-ups & expired cards', '9:00–9:30', 30, 'Weekly', d),
    make('Mindbody Admin (continued)', '9:30–10:00', 30, 'Weekly', d),
    make('Social media post + reel publish', '10:00–10:30', 15, 'Weekly', d),
    make('Membership retention outreach', '10:30–11:00', 30, 'Weekly', d),
    make('Specialty event/workout scheduling', '12:00–12:30', 30, 'Weekly', d),
  ]
}

function wednesdayTasks(d) {
  return [
    make('Content Creation: reels/graphics for social', '9:00–10:00', 60, 'Weekly', d),
    make('Event planning: member mingle, bonding, community', '10:00–10:30', 30, 'Monthly', d),
    make('Coach feedback, supplies & improvements check-in', '10:30–11:00', 30, 'Weekly', d),
    make('Social media engagement & DM responses', '12:00–12:30', 30, 'Weekly', d),
  ]
}

function thursdayTasks(d) {
  return [
    make('Mindbody Admin: Expiring contracts & cancellations', '9:00–9:30', 30, 'Weekly', d),
    make('Challenge check-in: participant outreach', '9:30–10:00', 30, 'Weekly', d),
    make('Merch/supply coordination with Carolina Prints', '10:00–10:30', 30, 'Monthly', d),
    make('Social media post + engagement check', '10:30–11:00', 30, 'Weekly', d),
    make('Event planning follow-up', '12:00–1:00', 60, 'As Needed', d),
  ]
}

function fridayTasks(d) {
  return [
    make('Weekly recap & Sunday prep notes', '9:00–9:30', 30, 'Weekly', d),
    make('Social media post scheduling', '9:30–10:00', 30, 'Weekly', d),
    make('EOW Mindbody check: class attendance cleanup', '10:00–10:30', 30, 'Weekly', d),
    make('Admin catch-up / flex time', '10:30–11:00', 30, 'Weekly', d),
    make('Monthly planning review: month-ahead scheduling', '12:00–12:30', 30, 'Monthly', d),
  ]
}
