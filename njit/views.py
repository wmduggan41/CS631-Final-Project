import logging

from django.shortcuts import render
from django.http import HttpResponse
from django.views import View
from django.db import IntegrityError

from njit.models import Student, Department, Course, Section, Staff, Registrations
from njit.forms import StudentIDForm, DepartmentForm, CourseForm, SectionForm


class RegistrationView(View):

    requires_student = True
    student = None
    course = None

    def get(self, request):
        return self._next_step(request, StudentIDForm)

    def post(self, request):

        student_id = request.POST.get('student_id')
        dept_code = request.POST.get('dept_code')
        course_code = request.POST.get('course_code')
        section_no = request.POST.get('section_no')

        if self.requires_student:
            try:
                student = Student.objects.get(student_id=student_id)
            except Student.DoesNotExist:
                return HttpResponse(f"That student ID does not exist")
            self.student = student

            if not student_id:
                return self._next_step(request, StudentIDForm)

        initial = {'student_id': student_id}
        if not dept_code:
            return self._next_step(request, DepartmentForm(initial=initial))
        initial['dept_code'] = dept_code

        if not course_code:
            return self._next_step(request, CourseForm(dept_code=dept_code, initial=initial))
        initial['course_code'] = course_code

        try:
            course = Course.objects.get(course_code=course_code)
        except Department.DoesNotExist:
            return HttpResponse(f"That Section does not exist")

        if not section_no:
            return self._next_step(request, SectionForm(course_code=course_code, initial=initial))

        try:
            section = Section.objects.get(sec_no=section_no, course_code=course_code)
        except Department.DoesNotExist:
            return HttpResponse(f"That Section does not exist")

        return self._handle_successful_request(request, student_id, section, course)

    def _next_step(self, request, form):
        return render(request, 'register.html', {'form': form})

    def _handle_successful_request(self, request, *args):
        student_id = args[0]
        section = args[1]
        course = args[2]
        try:
            Registrations.objects.create(
                student_id=student_id,
                sec_no=section,
                course_code=course
            )
        except IntegrityError as e:
            logging.error("Database Integrity Error", exc_info=True)

            # todo: helpful error messages

            return HttpResponse(f"There was an error with your request. \n\n DETAILS:\n{e})")

        instructor = Staff.objects.get(staff_ssn=section.instructor_ssn.staff_ssn)
        context = {
            'staff_name': instructor.staff_name,
            'course_name': course.course_name,
            'times': section.times
        }
        return render(request, 'register_complete.html', context)


class SectionListView(RegistrationView):

    requires_student = False

    def get(self, request):
        return self._next_step(request, DepartmentForm())

    def _handle_successful_request(self, request, *args):
        section = args[1]
        course = args[2]
        context = {
            'section': section,
            'course': course,
            'instructor': section.instructor_ssn,
            'students': section.students.values(
                'student_id', 'student__student_name', 'student__major', 'student__student_year').order_by(
                'student__student_name')
        }
        return render(request, 'class_list.html', context)
