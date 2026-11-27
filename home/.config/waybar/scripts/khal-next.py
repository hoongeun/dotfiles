#!/usr/bin/env python3
"""
Waybar module showing next calendar event from khal
"""

import subprocess
from datetime import datetime, timedelta
import re


def get_next_event():
    """Get next event from khal within 7 days"""
    try:
        result = subprocess.run(
            ['khal', 'list', 'today', '7d', '--day-format', '', '--format', '{start-date} {start-time} {title}'],
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode != 0:
            return None

        lines = result.stdout.strip().split('\n')
        if not lines or lines[0] == '':
            return None

        # Parse first event
        for line in lines:
            line = line.strip()
            if line:
                event = parse_event(line)
                if event:
                    return event

        return None

    except Exception:
        return None


def parse_event(line):
    """Parse khal event line"""
    try:
        # Format: YYYY-MM-DD HH:MM Title
        # or just: YYYY-MM-DD Title (for all-day events)
        match = re.match(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})\s+(.+)', line)

        if match:
            date_str = match.group(1)
            time_str = match.group(2)
            title = match.group(3)
            event_dt = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
            return {
                'datetime': event_dt,
                'title': title,
                'time': time_str
            }

        # Try all-day event format
        match = re.match(r'(\d{4}-\d{2}-\d{2})\s+(.+)', line)
        if match:
            date_str = match.group(1)
            title = match.group(2)
            event_dt = datetime.strptime(date_str, "%Y-%m-%d")
            return {
                'datetime': event_dt,
                'title': title,
                'time': '00:00',
                'all_day': True
            }

    except Exception:
        pass

    return None


def format_event(event):
    """Format event"""
    if not event:
        return "📅 일정 없음"

    now = datetime.now()
    event_dt = event['datetime']
    title = event['title']

    # Truncate title to 20 characters
    if len(title) > 20:
        title = title[:20] + "..."

    # Calculate time difference
    today = now.date()
    tomorrow = today + timedelta(days=1)
    day_after_tomorrow = today + timedelta(days=2)
    event_date = event_dt.date()

    # Today's event
    if event_date == today:
        time_diff = event_dt - now

        # Less than 1 hour
        if time_diff.total_seconds() < 0:
            # Event passed, should not happen if khal filters correctly
            return "📅 일정 없음"

        hours = int(time_diff.total_seconds() // 3600)
        minutes = int((time_diff.total_seconds() % 3600) // 60)

        if hours == 0:
            time_str = f"{minutes}분 후"
        else:
            time_str = f"{hours}시간 후"

        return f"📅 {time_str} {title}"

    # Tomorrow's event
    elif event_date == tomorrow:
        return f"📅 내일 {event['time']} {title}"

    # Day after tomorrow
    elif event_date == day_after_tomorrow:
        return f"📅 모레 {event['time']} {title}"

    # Later events
    else:
        weekdays = ['월', '화', '수', '목', '금', '토', '일']
        weekday = weekdays[event_dt.weekday()]
        month = event_dt.month
        day = event_dt.day

        return f"📅 {month}월{day}일({weekday}) {event['time']} {title}"


def main():
    event = get_next_event()
    output = format_event(event)
    print(output)


if __name__ == '__main__':
    main()
