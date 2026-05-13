import React, { useState } from 'react'
import { nextWeekday, formatLong, dateKey } from '../hooks/useTaskStore'

export default function DeferModal({ sourceDate, incompleteCount, onDefer, onClose }) {
  const [targetDate, setTargetDate] = useState(() => nextWeekday(sourceDate))
  const [confirming, setConfirming] = useState(false)

  const quickDates = getNextWeekdays(sourceDate, 5)

  function handleSubmit() {
    if (!confirming) { setConfirming(true); return }
    onDefer(targetDate)
    onClose()
  }

  const targetKey = dateKey(targetDate)

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal">
        <div className="modal-header">
          <h2>Move Uncompleted Tasks</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>

        <div className="modal-body">
          <div className="defer-summary">
            <span className="defer-count">{incompleteCount}</span>
            <span> task{incompleteCount !== 1 ? 's' : ''} will be moved</span>
          </div>

          <label className="field-label">Quick select</label>
          <div className="quick-dates">
            {quickDates.map(d => {
              const k = dateKey(d)
              const active = k === targetKey
              return (
                <button
                  key={k}
                  className={`quick-date-btn ${active ? 'active' : ''}`}
                  onClick={() => { setTargetDate(d); setConfirming(false) }}
                >
                  <span className="qd-day">{d.toLocaleDateString('en-US', { weekday: 'short' })}</span>
                  <span className="qd-date">{d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>
                </button>
              )
            })}
          </div>

          <label className="field-label" htmlFor="target-date">Or pick a date</label>
          <input
            id="target-date"
            type="date"
            className="date-input"
            value={targetKey}
            min={dateKey(nextWeekday(sourceDate))}
            onChange={e => {
              const [y, m, d] = e.target.value.split('-').map(Number)
              setTargetDate(new Date(y, m - 1, d))
              setConfirming(false)
            }}
          />
        </div>

        <div className="modal-footer">
          <button className="btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn-primary btn-orange" onClick={handleSubmit}>
            {confirming
              ? `Confirm: move to ${formatLong(targetDate)}?`
              : `Move ${incompleteCount} task${incompleteCount !== 1 ? 's' : ''} to ${targetDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })}`}
          </button>
        </div>
      </div>
    </div>
  )
}

function getNextWeekdays(after, count) {
  const dates = []
  let cursor = new Date(after)
  while (dates.length < count) {
    cursor = nextWeekday(cursor)
    dates.push(new Date(cursor))
  }
  return dates
}
