pro summarize_bin_files,file_pattern

	; Prints a simple summary for each CAMx binary file given in pattern:
	; file1 (Type), nx x ny x nz
	;   Spec 1 min/avg/max/rsd
	;   Spec 2 min/avg/max/rsd
	; file2 (Type), nx x ny x nz
	;   ...
	
	; To calculate a numerically stable average and standard deviation,
	; we use the algorithm by  Donald E. Knuth (1998). The Art of Computer Programming, volume 2: Seminumerical Algorithms
	
	; The idea is to run this for IC/INST/BC/EMISS before running the model
	; Also supports AVERAGE and hence CPA files
	
	; Suppress Math errors completely here
	!EXCEPT=0
	
	fichiers = file_search(strtrim(file_pattern,2),count=n_fichiers)
	if n_fichiers le 0L then message,'no files found.'
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Iterate over input files
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	for i_file=0,n_fichiers - 1 do begin
	
		current_input_file = fichiers[i_file]

		; Parse the files header
		hp=obj_new('header_parser',current_input_file,1)
	
		; Get number of species in average file
		scalars=hp->get_scalars()
		
		; How long is the header?
		header_length=hp->get_header_length()
		
		
		; Get filetype
		type=scalars->get('type')

		; Get dimensions
		num_input_species=scalars->get('nspec')
		nx = scalars->get('nx')
		ny = scalars->get('ny')
		nz = scalars->get('nz')
		

		; Get list of species and their indexes in the file
		species=hp->get_species()
		
		;get array of species
		species_arr = hp->get_species_arr()
		
		; Number of species
		nspec=n_elements(species_arr)
		
		; These are intermediate variables needed for the 
		; incremental calculation
		
		cells_seen = fltarr(nspec) ; number of cells looked at
		
		species_min = fltarr(nspec) ; running min
		species_max = fltarr(nspec) ; running max
		species_avg = fltarr(nspec) ; running average
		species_prevar = fltarr(nspec) ; running pre-variance
		
		;; Print data
		print, current_input_file + " (" + type + ") " + strtrim(nx,2) + "x" + strtrim(ny,2) + "x" + strtrim(nz,2)
		
		; Prepare data structures
		case type of
		
			'AVERAGE': begin
			              	avg_arr_slice=fltarr(nx, ny)
			              	units='(ppmv or ug/m**3)'
			           end
		
			'AIRQUALITY': begin

			              	ic_arr_slice=fltarr(nx, ny)
			              	units='(ppmv or ug/m**3)'
			              	
			              end
			'BOUNDARY':   begin
			
			              	; Our concentration arrays have these dimensions
			                ; (nx,nz | ny,nz),face,species,time
			                ; We group those of the same size together (E/W and N/S)
			                ; Note that in the file it is written nz|ny,
			                ; so we need to transpose
			                
			                ;West and East borders
			                bc_west_east_arr_slice=fltarr(nz,ny)
			                
			                ;South and North borders
			                bc_south_north_arr_slice=fltarr(nz,nx)
			                
			                units='(ppmv or ug/m**3)'
			                
			              end

			'EMISSIONS':  begin
			               emiss_arr_slice=fltarr(nx, ny)
			               units='(mol/time*cell or g/time*cell)'
			              end


			'INSTANT':    begin
			               inst_arr_slice=fltarr(nx, ny)
			               units='(umol/m**3 or ug/m**3)'
			              end
			              
			else: message,"Type not supported: " + type
		
		endcase
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Open the current input file
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		openr,current_input_lun,current_input_file,/GET_LUN,/F77_UNFORMATTED,/SWAP_ENDIAN
		
		; skip big header
		skip_lun,current_input_lun,header_length
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Depending on the type, read the data
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
				case type of

				'AVERAGE': begin
					             ; Average file
					             	
					             while ~ EOF(current_input_lun) do begin
			
												; Skip header
												; Reading the time header into dummy variables
												ibdate_dummy=0
												btime_dummy=0.
												iedate_dummy=0
												etime_dummy=0.
												
												readu,current_input_lun,ibdate_dummy,btime_dummy,iedate_dummy,etime_dummy

					              for ispec=0,(num_input_species - 1) do begin

														for k = 0, nz - 1 do begin
		
							              	; Read data  plus dummies
															ione=1L
															mspec=hp->prefill(4,10)
															readu,current_input_lun,ione,mspec,avg_arr_slice
															
															; Current stats
															data=avg_arr_slice
															c_min = min(data)
															c_max = max(data)
															c_n = n_elements(data)
															
															; Update stats
															if (cells_seen[ispec] GT 0) then begin
																if c_min LT species_min[ispec] then species_min[ispec] = c_min
																if c_max GT species_max[ispec] then species_max[ispec] = c_max
															endif else begin
																species_min[ispec] = c_min
																species_max[ispec] = c_max
															endelse
															
															for i=0,c_n - 1 do begin
																if cells_seen[ispec] eq 0 then begin
																	; init (prevar[0] is 0, no need to fix)
																	species_avg[ispec] = data[i]
																endif else begin
																	; update average and variance
																	last_avg=species_avg[ispec]
																	species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																	species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
																endelse
																cells_seen[ispec] ++
															endfor ; update avg and prevar for each cell

	
						              	endfor ; layers
		
					              endfor ; species
					              
					             endwhile ; time loop
		
					            end ; AVG case
				              

				'AIRQUALITY': begin
				              	; IC file
				              	
					             while ~ EOF(current_input_lun) do begin
			
												; Skip header
												; Reading the time header into dummy variables
												ibdate_dummy=0
												btime_dummy=0.
												iedate_dummy=0
												etime_dummy=0.
												
												readu,current_input_lun,ibdate_dummy,btime_dummy,iedate_dummy,etime_dummy

					              	for ispec=0,(num_input_species - 1) do begin

														for k = 0, nz - 1 do begin
		
							              	; Read data  plus dummies
															ione=1L
															mspec=hp->prefill(4,10)
															readu,current_input_lun,ione,mspec,ic_arr_slice
															
															; Current stats
															data=ic_arr_slice
															c_min = min(data)
															c_max = max(data)
															c_n = n_elements(data)
															
															; Update stats
															if (cells_seen[ispec] GT 0) then begin
																if c_min LT species_min[ispec] then species_min[ispec] = c_min
																if c_max GT species_max[ispec] then species_max[ispec] = c_max
															endif else begin
																species_min[ispec] = c_min
																species_max[ispec] = c_max
															endelse
															
															for i=0,c_n - 1 do begin
																if cells_seen[ispec] eq 0 then begin
																	; init (prevar[0] is 0, no need to fix)
																	species_avg[ispec] = data[i]
																endif else begin
																	; update average and variance
																	last_avg=species_avg[ispec]
																	species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																	species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
																endelse
																cells_seen[ispec] ++
															endfor ; update avg and prevar for each cell
	
						              	endfor
		
					              	endfor ; species
					              	
					              endwhile ; time loop
	
				              end ; IC case
				              
				'BOUNDARY':   begin
												; BC file
												
												; west-east-south-north
				
												;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
												; loop for time
												;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
												while ~ EOF(current_input_lun) do begin
												
													; Skip header with time information
													; Reading the time header into dummy variables
													ibdate_dummy=0
													btime_dummy=0.
													iedate_dummy=0
													etime_dummy=0.
													
													readu,current_input_lun,ibdate_dummy,btime_dummy,iedate_dummy,etime_dummy
													
													;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
													;loop through available species 
													;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
													for ispec=0,(num_input_species - 1) do begin
													
														current_species=species_arr[ispec]

														; Here we go over the 2 faces W/E
														 for k=0,1 do begin
	
															; Read data  plus dummies
															ione=1L
															mspec=hp->prefill(4,10)
															readu,current_input_lun,ione,mspec,bc_west_east_arr_slice
															
															; Current stats
															data=bc_west_east_arr_slice
															c_min = min(data)
															c_max = max(data)
															c_n = n_elements(data)
															
															; Update stats
															if (cells_seen[ispec] GT 0) then begin
																if c_min LT species_min[ispec] then species_min[ispec] = c_min
																if c_max GT species_max[ispec] then species_max[ispec] = c_max
															endif else begin
																species_min[ispec] = c_min
																species_max[ispec] = c_max
															endelse
															
															for i=0,c_n - 1 do begin
																if cells_seen[ispec] eq 0 then begin
																	; init (prevar[0] is 0, no need to fix)
																	species_avg[ispec] = data[i]
																endif else begin
																	; update average and variance
																	last_avg=species_avg[ispec]
																	species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																	species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
																endelse
																cells_seen[ispec] ++
															endfor ; update avg and prevar for each cell

														endfor ; Faces
														
														; Here we go over the 2 faces S/N
														for l=0,1 do begin
														
															; ; Read data  plus dummies
															ione=1L
															mspec=hp->prefill(4,10)
															readu,current_input_lun,ione,mspec,bc_south_north_arr_slice
															
															; Current stats
															data=bc_south_north_arr_slice
															c_min = min(data)
															c_max = max(data)
															c_n = n_elements(data)
															
															; Update stats
															if (cells_seen[ispec] GT 0) then begin
																if c_min LT species_min[ispec] then species_min[ispec] = c_min
																if c_max GT species_max[ispec] then species_max[ispec] = c_max
															endif else begin
																species_min[ispec] = c_min
																species_max[ispec] = c_max
															endelse
															
															for i=0,c_n - 1 do begin
																if cells_seen[ispec] eq 0 then begin
																	; init (prevar[0] is 0, no need to fix)
																	species_avg[ispec] = data[i]
																endif else begin
																	; update average and variance
																	last_avg=species_avg[ispec]
																	species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																	species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
																endelse
																cells_seen[ispec] ++
															endfor ; update avg and prevar for each cell


														endfor ; Faces

													endfor ; Loop through available species

												endwhile ; Loop through time
												
											end ; BC case


				'EMISSIONS':  begin
				
												while ~ EOF(current_input_lun) do begin
		
													; Skip header
													; Reading the time header into dummy variables
													ibdate_dummy=0
													btime_dummy=0.
													iedate_dummy=0
													etime_dummy=0.
													
													readu,current_input_lun,ibdate_dummy,btime_dummy,iedate_dummy,etime_dummy
													
													;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
													;loop through available species 
													;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
													for ispec=0,(nspec - 1) do begin
														
														; Skip header and read slice

														; dummies
														ione=1L
														mspec=hp->prefill(4,10)
														readu,current_input_lun,ione,mspec,emiss_arr_slice
														
														; Current stats
														data=emiss_arr_slice
														c_min = min(data)
														c_max = max(data)
														c_n = n_elements(data)
														
														; Update stats
														if (cells_seen[ispec] GT 0) then begin
															if c_min LT species_min[ispec] then species_min[ispec] = c_min
															if c_max GT species_max[ispec] then species_max[ispec] = c_max
														endif else begin
															species_min[ispec] = c_min
															species_max[ispec] = c_max
														endelse
														
														for i=0,c_n - 1 do begin
															if cells_seen[ispec] eq 0 then begin
																; init (prevar[0] is 0, no need to fix)
																species_avg[ispec] = data[i]
															endif else begin
																; update average and variance
																last_avg=species_avg[ispec]
																species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
															endelse
															cells_seen[ispec] ++
														endfor ; update avg and prevar for each cell


													endfor ; emissions species
														
												endwhile ; emissions time loop
												
											end ; emissions
	
	
				'INSTANT':    begin
					             while ~ EOF(current_input_lun) do begin
			
												; Skip header
												; Reading the time header into dummy variables
												ibdate_dummy=0
												btime_dummy=0.
												iedate_dummy=0
												etime_dummy=0.
												
												readu,current_input_lun,ibdate_dummy,btime_dummy,iedate_dummy,etime_dummy

					              for ispec=0,(num_input_species - 1) do begin

														for k = 0, nz - 1 do begin
		
							              	; Read data  plus dummies
															ione=1L
															mspec=hp->prefill(4,10)
															readu,current_input_lun,ione,mspec,inst_arr_slice

															; Current stats
															data=inst_arr_slice
															c_min = min(data)
															c_max = max(data)
															c_n = n_elements(data)
														
															; Update stats
															if (cells_seen[ispec] GT 0) then begin
																if c_min LT species_min[ispec] then species_min[ispec] = c_min
																if c_max GT species_max[ispec] then species_max[ispec] = c_max
															endif else begin
																species_min[ispec] = c_min
																species_max[ispec] = c_max
															endelse
															
															for i=0,c_n - 1 do begin
																if cells_seen[ispec] eq 0 then begin
																	; init (prevar[0] is 0, no need to fix)
																	species_avg[ispec] = data[i]
																endif else begin
																	; update average and variance
																	last_avg=species_avg[ispec]
																	species_avg[ispec] = last_avg + (data[i] - last_avg) / cells_seen[ispec]
																	species_prevar[ispec] = species_prevar[ispec] + (data[i] - last_avg)*(data[i] - last_avg)
																endelse
																cells_seen[ispec] ++
															endfor ; update avg and prevar for each cell


						              	endfor
		
					              endfor ; species
					              
					             endwhile ; time loop
											end
			endcase


			; Calculate & Print data
			print,'min/avg/max/rsd ' + units
			
			; Print them sorted
			sorted=sort(species_arr)
			
			for iispec=0,(nspec - 1) do begin
				; translate to unsorted
				ispec=sorted[iispec]
			
				; RSD is ratio of sd by mean
				if species_avg[ispec] gt 0 then begin
					c_rsd=sqrt(species_prevar[ispec]/(cells_seen[ispec] - 1))/species_avg[ispec]
				endif else begin
					c_rsd=0.0
				endelse
				
				xsize=5
				delimiter=STRING(9B)

				sData = [species_arr[ispec],string(species_min[ispec],format='(F15.7)'),string(species_avg[ispec],format='(F15.7)'),string(species_max[ispec],format='(F15.7)'),string(c_rsd,format='(F15.7)')]
				sData[0:xsize-2,*] = sData[0:xsize-2,*] + delimiter
				
				print,sData
			endfor

		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Free the current input LUN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		FREE_LUN,current_input_lun

	endfor ; files
	
	
end 