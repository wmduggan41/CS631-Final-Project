from django.db import models


class Assignment(models.Model):
    staff_ssn = models.OneToOneField('Staff', models.DO_NOTHING, db_column='staff_ssn', primary_key=True)
    course_code = models.ForeignKey('Section', models.DO_NOTHING, related_name='course_assignments', db_column='course_code')
    sec_no = models.ForeignKey('Section', models.DO_NOTHING, related_name='section_assignments', db_column='sec_no')

    class Meta:
        managed = False
        db_table = 'assignment'
        unique_together = (('staff_ssn', 'course_code', 'sec_no'),)


class Building(models.Model):
    build_id = models.IntegerField(primary_key=True)
    build_name = models.CharField(max_length=50, blank=True, null=True)
    location = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'building'


class Course(models.Model):
    course_code = models.CharField(primary_key=True, max_length=6)
    course_name = models.CharField(max_length=30, blank=True, null=True)
    credit = models.IntegerField(blank=True, null=True)
    ta_hrs_req = models.IntegerField(blank=True, null=True)
    dept_code = models.CharField(max_length=3, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'course'


class Department(models.Model):
    dept_code = models.CharField(primary_key=True, max_length=3)
    dept_name = models.CharField(max_length=30, blank=True, null=True)
    annual_budget = models.IntegerField(blank=True, null=True)
    dept_location = models.IntegerField(blank=True, null=True)
    dept_chair = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'department'


class FacultyDepartment(models.Model):
    staff_ssn = models.OneToOneField('Staff', models.DO_NOTHING, db_column='staff_ssn', primary_key=True)
    dept_code = models.ForeignKey(Department, models.DO_NOTHING, db_column='dept_code')

    class Meta:
        managed = False
        db_table = 'faculty_department'
        unique_together = (('staff_ssn', 'dept_code'),)


class Registrations(models.Model):
    student = models.ForeignKey('Student', models.DO_NOTHING, primary_key=True)
    sec_no = models.ForeignKey('Section', models.DO_NOTHING, related_name='students', db_column='sec_no')
    course_code = models.ForeignKey('Course', models.DO_NOTHING, related_name='course_registrations', db_column='course_code')

    class Meta:
        managed = False
        db_table = 'registrations'
        unique_together = (('student', 'course_code'),)


class Room(models.Model):
    room_no = models.IntegerField(primary_key=True)
    capacity = models.IntegerField(blank=True, null=True)
    audio_visual = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'room'


class Section(models.Model):
    sec_no = models.IntegerField(primary_key=True)
    course_code = models.ForeignKey(Course, models.DO_NOTHING, db_column='course_code')
    max_enroll = models.IntegerField(blank=True, null=True)
    instructor_ssn = models.ForeignKey('Staff', models.DO_NOTHING, db_column='instructor_ssn')

    class Meta:
        managed = False
        db_table = 'section'
        unique_together = (('sec_no', 'course_code'),)

    @property
    def times(self):
        srs = [
            f"{sr.weekday} {sr.time} in {sr.build.build_name} room {sr.room_no_id}"
            for sr in self.section_rooms.all()
        ]
        return ", ".join(srs)

    @property
    def location(self):
        return self


class SectionInRoom(models.Model):
    build = models.OneToOneField(Building, models.DO_NOTHING, primary_key=True)
    room_no = models.ForeignKey(Room, models.DO_NOTHING, db_column='room_no')
    course_code = models.ForeignKey(Course, models.DO_NOTHING, db_column='course_code')
    sec_no = models.ForeignKey(Section, models.DO_NOTHING, db_column='sec_no', related_name='section_rooms')
    weekday = models.CharField(max_length=2)
    time = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'section_in_room'
        unique_together = (('build', 'room_no', 'course_code', 'sec_no', 'weekday', 'time'),)


class Staff(models.Model):
    staff_ssn = models.IntegerField(primary_key=True)
    staff_name = models.CharField(max_length=30, blank=True, null=True)
    staff_add = models.CharField(max_length=100, blank=True, null=True)
    staff_salary = models.IntegerField(blank=True, null=True)
    function = models.CharField(max_length=20, blank=True, null=True)
    rank = models.CharField(max_length=10, blank=True, null=True)
    course_load = models.IntegerField(blank=True, null=True)
    work_hr = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'staff'


class Student(models.Model):
    student_id = models.IntegerField(primary_key=True)
    student_name = models.CharField(max_length=50, blank=True, null=True)
    student_add = models.CharField(max_length=80, blank=True, null=True)
    student_ssn = models.IntegerField(blank=True, null=True)
    student_year = models.IntegerField(blank=True, null=True)
    student_hs = models.CharField(max_length=30, blank=True, null=True)
    major = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'student'
