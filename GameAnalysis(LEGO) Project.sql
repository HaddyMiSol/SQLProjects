--What is the total number of parts per the theme
 
  Create view dbo.analytics_page as

 SELECT s.set_num, s.name as set_name, s.theme_id, s.year, cast(s.num_parts as numeric) num_parts, t.name as theme_name,p.name as parent_theme_name, t.parent_id 
 FROM dbo.sets s
 LEFT JOIN dbo.themes t
 ON s.theme_id= t.id
 LEFT JOIN dbo.themes p
 ON t.parent_id= p.id

 SELECT * FROM Rebrickable..analytics_page

 SELECT theme_name, sum(num_parts) as total_num_parts
 FROM dbo.analytics_page
 --WHERE parent_theme_name is not null
 GROUP BY theme_name
 ORDER BY 2 DESC

 --What is the total number of parts per year and per theme

 SELECT  year, sum(num_parts) as total_num_parts
 FROM dbo.analytics_page
 --WHERE parent_theme_name is not null
 GROUP BY year
 ORDER BY 2 DESC

 --How many sets released in each century

 ALTER view [dbo].[analytics_page] as
 SELECT s.set_num, s.name as set_name, s.theme_id, s.year, cast(s.num_parts as numeric) num_parts, t.name as theme_name,p.name as parent_theme_name, t.parent_id, 
 CASE 
      WHEN s.year BETWEEN 1901 and 1999 THEN '20th Century'
      WHEN s.year BETWEEN 2000 and 2200 THEN '21st Century'
 END 
 AS Century
 FROM dbo.sets s
 LEFT JOIN dbo.themes t
 ON s.theme_id= t.id
 LEFT JOIN dbo.themes p
 ON t.parent_id= p.id
 GO


 SELECT Century, Count (set_name) as total_set_num
 FROM dbo.analytics_page
 --WHERE parent_theme_name is not null
 GROUP BY Century
 ORDER BY 2 DESC

 --How many % of sets released in the 21st Century were "Trains" themed

 Update 
dbo.analytics_page
SET theme_name = CASE WHEN theme_name = 'trains' THEN 'train'
	                    ELSE theme_name
	                    END
 
 SELECT total_set_num as Total_train_set, Percentage as Percentage_train_set 
 FROM
 (
 SELECT Century, Count (set_name) as total_set_num, theme_name, Sum(Count (set_name)) OVER() as Rollingtotal_set_num,
 cast(1.00 * Count (set_name) / sum(Count (set_name)) OVER() as decimal(5,4))*100 Percentage
 FROM dbo.analytics_page
 WHERE  Century= '21st Century'
 GROUP BY Century, theme_name
 --ORDER BY 2 DESC
 )m
 WHERE theme_name LIKE '%train%' 

 
 --What was the popular theme by year in the 21st Century

 SELECT *
 FROM
 (
 SELECT Century, year, theme_name, Count (theme_name) as total_theme_num, ROW_NUMBER() OVER (partition by year ORDER BY Count (theme_name) DESC)  RN
 FROM dbo.analytics_page
 WHERE  Century= '21st Century' --AND parent_theme_name is not null
 GROUP BY Century, year, theme_name
 )m
 WHERE RN =1 
 ORDER BY 2,4 DESC


 --What is the most produced color of LEGO in terms of quantity of parts

 
 SELECT color_name, sum(quantity) as total_quantity_parts
 FROM
 (
 SELECT inv.color_id, inv.inventory_id, cast(inv.part_num as int) inv_part_num, cast(inv.quantity as numeric) quantity, inv.is_spare, col.name as color_name, col.rgb, pt.name as part_name, pt.part_material, pc.name as category_name
 FROM dbo.inventory_parts inv
 INNER JOIN dbo.colors col
 ON inv.color_id = col.id
 INNER JOIN dbo.sets pt
 ON inv.part_num = pt.part_num
 INNER JOIN dbo.part_categories pc
 ON pt.part_cat_id = pc.id
 )m

 GROUP BY color_name
 ORDER BY total_quantity_parts DESC

 