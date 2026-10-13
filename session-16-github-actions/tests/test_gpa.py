import pytest

from app.gpa import calculate_gpa, grade_points


def test_grade_points_is_case_insensitive():
    assert grade_points("a") == 4.0
    assert grade_points(" b+ ") == 3.3


def test_weighted_gpa():
    result = calculate_gpa([
        {"credits": 4, "grade": "A"},
        {"credits": 3, "grade": "B"},
        {"credits": 2, "grade": "C"},
    ])
    assert result == {"gpa": 3.22, "total_credits": 9}


def test_unknown_grade_is_rejected():
    with pytest.raises(ValueError, match="unknown grade"):
        calculate_gpa([{"credits": 3, "grade": "Z"}])


@pytest.mark.parametrize("credits", [0, -1, 11, "3", True])
def test_invalid_credits_are_rejected(credits):
    with pytest.raises(ValueError, match="credits"):
        calculate_gpa([{"credits": credits, "grade": "A"}])


def test_empty_course_list_is_rejected():
    with pytest.raises(ValueError, match="at least one course"):
        calculate_gpa([])
