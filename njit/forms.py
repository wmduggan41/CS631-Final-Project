from django import forms
from njit.models import Department, Course, Section


class StudentIDForm(forms.Form):
    header = "Enter your Student ID"
    student_id = forms.CharField()


class DepartmentForm(forms.Form):
    header = "Select a Department"
    dept_code = forms.ChoiceField()
    student_id = forms.CharField(widget=forms.HiddenInput())

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['dept_code'].choices = Department.objects.values_list('dept_code', 'dept_name')


class CourseForm(forms.Form):
    header = "Select a Course"
    course_code = forms.ChoiceField()
    dept_code = forms.ChoiceField(widget=forms.HiddenInput())
    student_id = forms.CharField(widget=forms.HiddenInput())

    def __init__(self, dept_code, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['course_code'].choices = Course.objects.filter(
            dept_code=dept_code
        ).values_list('course_code', 'course_name')


class SectionForm(forms.Form):
    header = "Select a Section"
    section_no = forms.ChoiceField()
    course_code = forms.ChoiceField(widget=forms.HiddenInput())
    dept_code = forms.ChoiceField(widget=forms.HiddenInput())
    student_id = forms.CharField(widget=forms.HiddenInput())

    def __init__(self, course_code, *args, **kwargs):
        super().__init__(*args, **kwargs)
        sections = Section.objects.filter(course_code=course_code)
        section_choices = [
            (section.sec_no, f"{section.instructor_ssn.staff_name} | "
                             f" {section.times}")
            for section in sections
        ]
        self.fields['section_no'].choices = section_choices

    def _parse_sr(self, section):
        srs = [
            f"{sr.weekday} {sr.time}"
            for sr in section.section_rooms.all()
        ]
        return ", ".join(srs)
