"""GPA calculation on a 4.0 scale."""

GRADE_POINTS = {
    "A": 4.0,
    "A-": 3.7,
    "B+": 3.3,
    "B": 3.0,
    "B-": 2.7,
    "C+": 2.3,
    "C": 2.0,
    "D": 1.0,
    "F": 0.0,
}


def grade_points(grade: str) -> float:
    """Return the grade points for a letter grade such as "B+"."""
    key = grade.strip().upper()
    if key not in GRADE_POINTS:
        raise ValueError(f"unknown grade {grade!r}; use one of {', '.join(GRADE_POINTS)}")
    return GRADE_POINTS[key]


def calculate_gpa(courses: list[dict]) -> dict:
    """Credit-weighted GPA for a list of {"credits": number, "grade": letter} items."""
    if not courses:
        raise ValueError("at least one course is required")
    total_credits = 0.0
    weighted = 0.0
    for course in courses:
        credits = course.get("credits")
        if not isinstance(credits, (int, float)) or isinstance(credits, bool) or not 0 < credits <= 10:
            raise ValueError("credits must be a number between 0 and 10")
        weighted += credits * grade_points(str(course.get("grade", "")))
        total_credits += credits
    return {"gpa": round(weighted / total_credits, 2), "total_credits": total_credits}
