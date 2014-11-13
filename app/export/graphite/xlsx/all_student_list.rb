class Graphite::Xlsx::AllStudentList < Graphite::Xlsx::StudentList

	def initialize(students)
		super(students)

		@students = Student
		.where(id: students.to_a)
		.includes(:user, :student_studies => [:studies => [:course => :translations,
														 :study_type => :translations, :study_degree => :translations,
														 :specialization => :translations]],
				:accepted_elective_enrollments => [:block => :translations,
													 :elective_module => :translations, :elective_block =>
													 [:elective_block_studies, :translations]]).load
	end

	protected

	def rows
		students.each do |student|
			if student.accepted_elective_enrollments.present?
				student.accepted_elective_enrollments.each do |enrollment|
					student_studies = student.student_studies.detect do |ss|
						enrollment.elective_block.elective_block_studies.any? do |ebs|
							ss.studies_id == ebs.studies_id
						end
					end
					if student_studies.present?
						row = [
							student.surname_name,
							student.user.email,
							student.index_number,
							student.passed_ects,
							student.average_grade,
							student_studies.studies.course.name,
							student_studies.studies.study_degree.name,
							student_studies.studies.study_type.name,
							student_studies.studies.specialization.try(:name),
							student_studies.semester_number,
							enrollment.elective_block.name,
							enrollment.block_id.present? ? enrollment.block.try(:name) :
							enrollment.elective_module.try(:name)
						]
						sheet.add_row row
					end
				end
			else
				student.student_studies.each do |ss|
					row = [
						student.surname_name,
						student.user.email,
						student.index_number,
						student.passed_ects,
						student.average_grade,
						ss.studies.course.name,
						ss.studies.study_degree.name,
						ss.studies.study_type.name,
						ss.studies.specialization.try(:name),
						ss.semester_number,
					]
					sheet.add_row row
				end

			end
		end
	end

end