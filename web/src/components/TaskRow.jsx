import React from 'react'
import { formatShort } from '../hooks/useTaskStore'

const FREQ_COLORS = {
  Daily:    { bg: '#dbeafe', text: '#1d4ed8' },
  Weekly:   { bg: '#ede9fe', text: '#7c3aed' },
  Monthly:  { bg: '#ffedd5', text: '#c2410c' },
  'As Needed': { bg: '#ccfbf1', text: '#0f766e' },
}

export default function TaskRow({ task, onToggle }) {
  const colors = FREQ_COLORS[task.frequency] || FREQ_COLORS.Daily
  const dur = task.minutes >= 60
    ? `${Math.floor(task.minutes / 60)}hr${task.minutes % 60 ? ` ${task.minutes % 60}min` : ''}`
    : `${task.minutes}min`

  return (
    <div
      className={`task-row ${task.isCompleted ? 'completed' : ''}`}
      onClick={onToggle}
      role="checkbox"
      aria-checked={task.isCompleted}
      tabIndex={0}
      onKeyDown={e => (e.key === ' ' || e.key === 'Enter') && onToggle()}
    >
      <button
        className={`checkbox ${task.isCompleted ? 'checked' : ''}`}
        onClick={e => { e.stopPropagation(); onToggle() }}
        aria-label={task.isCompleted ? 'Mark incomplete' : 'Mark complete'}
      >
        {task.isCompleted && (
          <svg viewBox="0 0 12 10" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="1,5 4,9 11,1" />
          </svg>
        )}
      </button>

      <div className="task-content">
        <span className="task-title">{task.title}</span>
        <div className="task-meta">
          <span className="meta-chip">
            <ClockIcon /> {task.timeSlot}
          </span>
          <span className="meta-chip">
            <TimerIcon /> {dur}
          </span>
          <span className="freq-badge" style={{ background: colors.bg, color: colors.text }}>
            {task.frequency}
          </span>
          {task.isDeferred && task.originalDate && (
            <span className="deferred-tag">
              ↪ moved from {formatShort(task.originalDate)}
            </span>
          )}
        </div>
      </div>
    </div>
  )
}

function ClockIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
      <polyline points="12,6 12,12 16,14" />
    </svg>
  )
}

function TimerIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="13" r="8" />
      <polyline points="12,9 12,13" />
      <line x1="9" y1="3" x2="15" y2="3" />
    </svg>
  )
}
